require 'run_loop'

calabash = ENV['CALABASH']

case calabash
  when '2x'
    RunLoop.log_debug("Running with Calabash 2.x")
    RunLoop.log_error("Calabash 2.x implemention is broken.")
    RunLoop.log_error("Requires an update for run-loop and Xcode 7")
    exit 1
  when '0x'
    RunLoop.log_debug("Running with Calabash 0.x")
  else
    RunLoop.log_error("Expected CALABASH to be '2x' or '0x' but found '#{calabash}'")
    exit 1
end

require 'rspec'

