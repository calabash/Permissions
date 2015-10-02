require 'luffa'

calabash = ENV['CALABASH']

case calabash
  when '20'
    Luffa.log_info("Running with Calabash 2.0")
    Luffa.log_error("Calabash 2.0 implemention is broken.")
    Luffa.log_error("Requires an update for run-loop and Xcode 7")
    exit 1
  when '0x'
    Luffa.log_info("Running with Calabash 0.x")
  else
    Luffa.log_error("Expected CALABASH to be '20' or '0x' but found '#{calabash}'")
    exit 1
end

require 'rspec'

