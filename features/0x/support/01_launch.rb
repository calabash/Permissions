module Permissions
  class DeviceAgent
    require "singleton"
    include Singleton

    def self.query(mark, options={})
      DeviceAgent.instance.query(mark, options)
    end

    def self.alert_visible?
      DeviceAgent.instance.alert_visible?
    end

    def self.spring_board_alert_visible?
      DeviceAgent.instance.spring_board_alert_visible?
    end

    def self.shutdown
      DeviceAgent.instance.shutdown
    end

    # Use DeviceAgent to query for elements.
    #
    # @example Query by identifier.
    #
    #   DeviceAgent.query("login")
    #
    # @example Query by type
    #
    #   DeviceAgent.query("Button", {:specifier => :type})
    #
    # @example Query by text
    #
    #   DeviceAgent.query("Log In", {:specifier => :text})
    #
    # @param [String] mark An identifier.
    # @param [Hash] options Control over the query
    # @option options :all (true) Return all results, regardless of visibility.
    # @option options :specifier (:id) What to match the mark against.
    #
    # @return [Array<Hash>] An array of elements that match the query.
    def query(mark, options={})
      client.query(mark, options)
    end

    def alert_visible?
      client.alert_visible?
    end

    def spring_board_alert_visible?
      client.spring_board_alert_visible?
    end

    def shutdown
      performer = Permissions::Launchctl.instance.launcher.automator
      return if !performer

      if performer.name != :device_agent
        raise "The client is not DeviceAgent!"
      end

      performer.client.send(:shutdown)
    end

    private

    def client
      performer = Permissions::Launchctl.instance.launcher.automator
      if !performer
        raise "There is no client!"
      end

      if performer.name != :device_agent
        raise "The client is not DeviceAgent!"
      end

      @device_agent_client = performer.client
    end
  end
end

module Permissions
  class Launchctl
    require "singleton"
    include Singleton

    require "calabash-cucumber/launcher"
    require "calabash-cucumber/environment"

    attr_reader :first_launch
    attr_reader :launcher

    def initialize
      @first_launch = true
      @launcher = Calabash::Cucumber::Launcher.new
    end

    def launch(options)
      launcher.relaunch(options)
      @first_launch = false
    end

    def launcher
      @launcher
    end

    def first_launch
      @first_launch
    end

    def shutdown(world)
      world.send(:calabash_exit)
      performer = Permissions::Launchctl.instance.launcher.automator
      return if !performer

      if performer.name == :device_agent
        Permissions::DeviceAgent.shutdown
      end

      @first_launch = true
    end

    def lp_server_running?
      begin
        running = launcher.ping_app
      rescue Errno::ECONNREFUSED => _
        running = false
      end

      running
    end

    def device_agent_running?
      if launcher.instruments?
        raise RuntimeError, "Don't call this method if you are running with Instruments"
      end

      if launcher.automator.nil?
        return false
      end

      launcher.automator.client.running?
    end

    def running?
      return false if first_launch
      return false if !launcher.run_loop
      return false if !launcher.automator

      return false if !lp_server_running?

      running = true

      if !launcher.instruments?
        device_agent_running?
      end

      running
    end

    def xcode
      Calabash::Cucumber::Environment.xcode
    end

    def instruments
      Calabash::Cucumber::Environment.instruments
    end

    def simctl
      Calabash::Cucumber::Environment.simctl
    end

    def environment
      {
        :simctl => self.simctl,
        :instruments => self.instruments,
        :xcode => self.xcode
      }
    end

    def options
      @options ||= begin
        if xcode.version_gte_8?
          performer = {
            :gesture_performer => :device_agent
          }
        else
          performer = {
            :gesture_performer => :instruments
          }
        end

        performer.merge(environment)
      end
    end

    def device
      @device ||= RunLoop::Device.detect_device({}, xcode, simctl, instruments)
    end

    def reset_simulator_lang_locale_and_tcc
      if device.physical_device?
        raise "Should only be called when target is a simulator"
      else
        RunLoop::CoreSimulator.erase(device, {:simctl => simctl})
        set_sim_locale_and_lang(device)
      end
    end

    def maybe_reset_simulator_tcc(scenario)
      return if device.physical_device?

      names = scenario.tags.map { |tag| tag.name }

      # Before hook already reset the simulator
      return if names.include?("@reset_device_settings")

      RunLoop::TCC.deny(device, ensure_app)
    end

    def ensure_app
      app_path = File.expand_path("Products/app/Permissions.app")
      if !File.exist?(app_path)
        hash = RunLoop::Shell.run_shell_command(["make", "app"], {:log_cmd => true})
        if hash[:exit_status] != 0
          RunLoop.log_error("Could not build app; run: 'make app' to diagnose")
          exit hash[:exit_status]
        end
      end
      app_path
    end

    def ensure_ipa
      ipa_path = File.expand_path("Products/ipa/Permissions.ipa")
      if !File.exist?(ipa_path)
        hash = RunLoop::Shell.run_shell_command(["make", "ipa"], {:log_cmd => true})
        if hash[:exit_status] != 0
          RunLoop.log_error("Could not build ipa; run: 'make ipa' to diagnose")
          exit hash[:exit_status]
        end
      end
      ipa_path
    end

    def install_on_physical_device
      begin
        Calabash::IDeviceInstaller.new(ensure_ipa, device.udid).install_app
      rescue => e
        RunLoop.log_error(e.message)
        exit 9
      end
    end

    def ensure_app_installed_on_device
      ideviceinstaller = Calabash::IDeviceInstaller.new(ensure_ipa, device.udid)
      unless ideviceinstaller.app_installed?
        begin
          ideviceinstaller.install_app
        rescue => e
          RunLoop.log_error(e.message)
          exit 9
        end
      end
    end

    def app_locale
      @app_locale = ENV["APP_LOCALE"] || "en_US"
    end

    def app_lang
      @app_lang = ENV["APP_LANG"] || "en-US"
    end

    def set_sim_locale_and_lang(sim)
      if device.physical_device?
        raise "Should only be called when target is a simulator"
      end

      RunLoop::CoreSimulator.set_locale(sim, app_locale)
      RunLoop::CoreSimulator.set_language(sim, app_lang)
    end
  end
end

Before("@reset_device_settings") do
  Permissions::Launchctl.instance.shutdown(self)

  if xamarin_test_cloud?
    ENV["RESET_BETWEEN_SCENARIOS"] = "1"
  elsif Permissions::Launchctl.instance.device.simulator?
    Permissions::Launchctl.instance.reset_simulator_lang_locale_and_tcc
  else
    # Requires Settings.app > General > Reset > Reset Location and Privacy
    # Could be automated with DeviceAgent.
    Permissions::Launchctl.instance.install_on_physical_device
  end
end

Before do |scenario|
  if !xamarin_test_cloud?
    if Permissions::Launchctl.instance.device.physical_device?
      Permissions::Launchctl.instance.ensure_app_installed_on_device
    end
  end

  options =
    {
      :args =>
      [
        "-AppleLanguages", "(#{Permissions::Launchctl.instance.app_lang})",
        "-AppleLocale", Permissions::Launchctl.instance.app_locale,
      ],

      #:uia_strategy => :preferences,
      #:uia_strategy => :host,
      #:uia_strategy => :shared_element,
      #:uia_strategy => :host,
      #:uia_timeout => 30
      #:gesture_performer => :device_agent,
  }.merge(Permissions::Launchctl.instance.environment)

  if Permissions::Launchctl.instance.first_launch
    Permissions::Launchctl.instance.maybe_reset_simulator_tcc(scenario)
    Permissions::Launchctl.instance.launch(options)

    if xamarin_test_cloud?
      ENV["RESET_BETWEEN_SCENARIOS"] = "0"
    end
  end
end

After do |scenario|
  if scenario.failed?
    Permissions::Launchctl.instance.shutdown(self)
  end

  # Super helpful for local testing.
  # if scenario.failed?
  #   exit!(9)
  # end
end

