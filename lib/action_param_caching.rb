require 'action_param_caching/railtie'
require 'action_param_caching/caching'
require 'action_controller/action_caching' # Find a way to trip the tests up with commenting this out

module ActionParamCaching
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :Caching
  end

  include Caching
end

ActionController::Base.send(:include, ActionParamCaching::Caching)
