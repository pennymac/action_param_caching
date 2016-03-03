require 'action_param_caching/railtie'
require 'action_param_caching/caching'

module ActionParamCaching
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :Caching
  end

  include Caching
end

ActionController::Base.send(:include, ActionParamCaching::Caching)
