require 'calabash-cucumber/launcher'

module LaunchControl

  @@launcher = nil
  @@is_first_launch = true
  @@alert_results_file = nil

  def self.launcher
    @@launcher ||= Calabash::Cucumber::Launcher.new
  end

  def self.launcher=(launcher)
    @@launcher = launcher
  end

  def self.alert_results_file
    @@alert_results_file
  end

  def self.reset_before_any_tests
    if @@is_first_launch
      if self.target_is_simulator?
        FileUtils.mkdir_p("tmp")
        @@alert_results_file = "tmp/alert_text_#{LaunchControl.app_lang}_sim.txt"
        if File.exist?(@@alert_results_file)
          FileUtils.rm_r(@@alert_results_file)
        end

        FileUtils.touch(@@alert_results_file)
        self.reset_simulator
      else
        FileUtils.mkdir_p("tmp")
        @@alert_results_file = "tmp/alert_text_#{LaunchControl.app_lang}_device.txt"
        if File.exist?(@@alert_results_file)
          FileUtils.rm_r(@@alert_results_file)
        end

        FileUtils.touch(@@alert_results_file)
      end
    end

    @@is_first_launch = false
  end

  def self.reset_simulator
    if !self.target_is_simulator?
      raise "Should only be called when target is a simulator"
    else
      target = self.target
      sim = RunLoop::Device.device_with_identifier(target)
      RunLoop::CoreSimulator.erase(sim)
      self.set_sim_locale_and_lang(sim)
    end
  end

  def self.target
    ENV['DEVICE_TARGET'] || RunLoop::Core.default_simulator
  end

  def self.target_is_simulator?
    RunLoop::Core.simulator_target?({:device_target => self.target})
  end

  def self.target_is_physical_device?
    !self.target_is_simulator?
  end

  def self.ensure_ipa
    ipa_path = File.expand_path('Products/ipa/Permissions.ipa')
    unless File.exist?(ipa_path)
      system('make', 'ipa')
    end
    ipa_path
  end

  def self.install_on_physical_device
    Calabash::IDeviceInstaller.new(self.ensure_ipa, self.target).install_app
  end

  def self.ensure_app_installed_on_device
    ideviceinstaller = Calabash::IDeviceInstaller.new(self.ensure_ipa, self.target)
    unless ideviceinstaller.app_installed?
      ideviceinstaller.install_app
    end
  end

  def self.app_locale
    @@app_locale = ENV["APP_LOCALE"] || "en_US"
  end

  def self.app_lang
    @aap_lang = ENV["APP_LANG"] || "en-US"
  end

  def self.set_sim_locale_and_lang(sim)
    if !self.target_is_simulator?
      raise "Should only be called when target is a simulator"
    end

    RunLoop::CoreSimulator.set_locale(sim, self.app_locale)
    RunLoop::CoreSimulator.set_language(sim, self.app_lang)
  end
end

Before('@reset_device_settings') do
  if xamarin_test_cloud?
    ENV['RESET_BETWEEN_SCENARIOS'] = '1'
  elsif LaunchControl.target_is_simulator?
    LaunchControl.reset_simulator
  else
    LaunchControl.install_on_physical_device
  end
end

Before do |_|
  if !xamarin_test_cloud?
    LaunchControl.reset_before_any_tests
  end

  launcher = LaunchControl.launcher

  options =
    {
      :args =>
      [
        "-AppleLanguages", "(#{LaunchControl.app_lang})",
        "-AppleLocale", LaunchControl.app_locale
      ],

      #:uia_strategy => :preferences,
      #:uia_strategy => :host,
      #:uia_strategy => :shared_element,
      #:uia_strategy => :host,
      #:uia_timeout => 30
      #:gesture_performer => :device_agent,
      #:shutdown_device_agent_before_launch => true
  }

  launcher.relaunch(options)
  launcher.calabash_notify(self)

  if xamarin_test_cloud?
    ENV['RESET_BETWEEN_SCENARIOS'] = '0'
  end
end

After do |_|

  if !xamarin_test_cloud? && uia_available?
    alert_results_file = LaunchControl.alert_results_file
    run_loop = LaunchControl.launcher.run_loop
    if run_loop
      log_file = run_loop[:log_file]
      lines = File.read(log_file).force_encoding("UTF-8")
      lines.split($-0).each do |line|
        if line[/capture/, 0]
          puts "#{line}"
          $stdout.flush
          File.open(alert_results_file, "a:UTF-8") do |file|
            file.puts(line)
          end
        end
      end
    end
  end
end

