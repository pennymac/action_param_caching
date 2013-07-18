require 'rspec'
require 'active_support/all'

require 'action_param_caching' # and any other gems you need

#Hash.send(:include, ActiveSupport::CoreExtensions::Hash) unless Hash.included_modules.include?(ActiveSupport::CoreExtensions::Hash)

RSpec.configure do |config|
  config.mock_with :mocha
  config.order = "random"
end