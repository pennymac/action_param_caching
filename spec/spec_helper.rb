require 'bundler/setup'

require 'action_controller'
require 'action_param_caching'

RSpec.configure do |config|
  config.mock_with :mocha
  config.order = "random"
end
