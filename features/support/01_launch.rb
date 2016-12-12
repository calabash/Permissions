
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
      @first_launch = true
      world.calabash_exit
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
      else
        running
      end
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
      if RunLoop::Environment.xtc?
        {}
      else
        environment
      end
    end

    def device
      @device ||= RunLoop::Device.detect_device({}, xcode, simctl, instruments)
    end

    def reset_simulator_lang_locale_and_tcc
      return if RunLoop::Environment.xtc?
      if device.physical_device?
        raise "Should only be called when target is a simulator"
      else
        RunLoop::CoreSimulator.erase(device, {:simctl => simctl})
        set_sim_locale_and_lang
      end
    end

    def maybe_reset_simulator_tcc(scenario)
      return if RunLoop::Environment.xtc?
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

    def set_sim_locale_and_lang
      if device.physical_device?
        raise "Should only be called when target is a simulator"
      end

      RunLoop::CoreSimulator.set_locale(device, app_locale)
      RunLoop::CoreSimulator.set_language(device, app_lang)
    end
  end
end

Before("@reset_device_settings") do
  if xamarin_test_cloud?
    ENV["RESET_BETWEEN_SCENARIOS"] = "1"
    Permissions::Launchctl.instance.shutdown(self)
  elsif Permissions::Launchctl.instance.device.simulator?
    Permissions::Launchctl.instance.shutdown(self)
    Permissions::Launchctl.instance.reset_simulator_lang_locale_and_tcc
  else
    Permissions::Launchctl.instance.shutdown(self)
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

    options = Permissions::Launchctl.instance.environment
    options[:args] = [
      "-AppleLanguages", "(#{Permissions::Launchctl.instance.app_lang})",
      "-AppleLocale", Permissions::Launchctl.instance.app_locale,
    ]

    if Permissions::Launchctl.instance.first_launch
      Permissions::Launchctl.instance.maybe_reset_simulator_tcc(scenario)
      Permissions::Launchctl.instance.launch(options)
    end

  else
    options = {}
    Permissions::Launchctl.instance.launch(options)
    if xamarin_test_cloud?
      ENV["RESET_BETWEEN_SCENARIOS"] = "0"
    end
  end
end

After do |scenario|

  case :shutdown
    when :shutdown
      if scenario.failed?
        calabash_exit
      end
    when :exit
      if !xamarin_test_cloud?
        if scenario.failed?
          exit!(9)
        else
          calabash_exit
        end
      end
    else
  end
end
