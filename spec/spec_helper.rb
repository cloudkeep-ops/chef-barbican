require 'chefspec'
require 'chefspec/server'
require 'chefspec/berkshelf'

RSpec.configure do |config|

  # Specify the Chef log_level (default: :warn)
  config.log_level = :warn

  # Specify the operating platform to mock Ohai data from (default: nil)
  config.platform = 'centos'

  # Specify the operating version to mock Ohai data from (default: nil)
  config.version = '6.5'
end

at_exit { ChefSpec::Coverage.report! }