require "irb/completion"
require "irb/ext/save-history"
require "benchmark"
require "run_loop"
require "pry"
require "calabash-cucumber/operations"

AwesomePrint.irb!

ARGV.concat [ "--readline",
              "--prompt-mode",
              "simple"]

IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = ".irb-history"

IRB.conf[:AUTO_INDENT] = true

IRB.conf[:PROMPT][:PERMISSIONS] = {
  :PROMPT_I => "permissions #{Calabash::Cucumber::VERSION}> ",
  :PROMPT_N => "permissions #{Calabash::Cucumber::VERSION}> ",
  :PROMPT_S => nil,
  :PROMPT_C => "> ",
  :AUTO_INDENT => false,
  :RETURN => "%s\n"
}

IRB.conf[:PROMPT_MODE] = :PERMISSIONS

Pry.config.history.should_save = false
Pry.config.history.should_load = false
require "pry-nav"

extend Calabash::Cucumber::Operations

def embed(x,y=nil,z=nil)
  puts "Screenshot at #{x}"
end

puts ""
puts "#       =>  Useful Methods  <=          #"
puts "> xcode       => Xcode instance"
puts "> instruments => Instruments instance"
puts "> simcontrol  => SimControl instance"
puts "> default_sim => Default simulator"
puts "> verbose     => turn on DEBUG logging"
puts "> quiet       => turn off DEBUG logging"
puts "> make_app    => build a new .app from sources"
puts ""

def xcode
  @xcode ||= RunLoop::Xcode.new
end

def instruments
  @instruments ||= RunLoop::Instruments.new
end

def simcontrol
  @simcontrol ||= RunLoop::SimControl.new
end

def default_sim
  @default_sim ||= lambda do
    name = RunLoop::Core.default_simulator(xcode)
    simcontrol.simulators.find do |sim|
      sim.instruments_identifier(xcode) == name
    end
  end.call
end

def verbose
  ENV["DEBUG"] = "1"
end

def quiet
  ENV["DEBUG"] = "1"
end

motd=["Let's get this done!", "Ready to rumble.", "Enjoy.", "Remember to breathe.",
      "Take a deep breath.", "Isn't it time for a break?", "Can I get you a coffee?",
      "What is a calabash anyway?", "Smile! You are on camera!", "Let op! Wild Rooster!",
      "Don't touch that button!", "I'm gonna take this to 11.", "Console. Engaged.",
      "Your wish is my command.", "This console session was created just for you."]
puts "#{motd.sample()}"


if ENV["APP"]
  app = ENV["APP"]
else
  app = File.expand_path("Products/app/Permissions.app")
  ENV["APP"] = app
end

unless File.exist?(app)
  raise "Expected app "#{app}" to exist.\nYou can build the app with `make app`"
end

puts "APP => '#{app}'"

def make_app
  system("make", "app")
end

def start_en(options={})
  sim = default_sim
  RunLoop::CoreSimulator.erase(sim)

  launch_options = {
    :uia_strategy => :preferences,
  }.merge(options)
  start_test_server_in_background(launch_options)
end

def start_danish(options={})
  sim = default_sim
  RunLoop::CoreSimulator.erase(sim)

  path = File.expand_path(File.join(sim.simulator_preferences_plist_path, "..", ".GlobalPreferences.plist"))
  pbuddy = RunLoop::PlistBuddy.new
  pbuddy.plist_set("AppleLocale", "string", "da_DA", path)

  xcrun = RunLoop::Xcrun.new
  cmd = ["PlistBuddy", "-c", "Add :AppleLanguages:0 string 'da'", path]
  xcrun.exec(cmd, {:log_cmd => true})

  launch_options = {
    :uia_strategy => :preferences,
    :args => ["-AppleLanguages", "(da)", "-AppleLocale da_DA"],
  }.merge(options)
  start_test_server_in_background(launch_options)
end

def start_dutch(options={})
  sim = default_sim
  RunLoop::CoreSimulator.erase(sim)

  path = File.expand_path(File.join(sim.simulator_preferences_plist_path, "..", ".GlobalPreferences.plist"))
  pbuddy = RunLoop::PlistBuddy.new
  pbuddy.plist_set("AppleLocale", "string", "nl_NL", path)

  xcrun = RunLoop::Xcrun.new
  cmd = ["PlistBuddy", "-c", "Add :AppleLanguages:0 string 'nl'", path]
  xcrun.exec(cmd, {:log_cmd => true})

  launch_options = {
    :uia_strategy => :preferences,
    :args => ["-AppleLanguages", "(nl)", "-AppleLocale nl_NL"],
  }.merge(options)
  start_test_server_in_background(launch_options)
end

