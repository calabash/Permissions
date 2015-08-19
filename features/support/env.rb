require 'calabash/ios'

World(Calabash::IOS)

Calabash::IOS.setup_defaults!

# Pry is not allowed on the Xamarin Test Cloud.  This will force a validation
# error if you mistakenly submit a binding.pry to the Test Cloud.
unless Calabash::Environment.xamarin_test_cloud?
  require 'pry'
  Pry.config.history.file = '.pry-history'
  require 'pry-nav'
end

