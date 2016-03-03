require 'rails/railtie'

module ActionParamCaching
  class Railtie < Rails::Railtie
    initializer 'action_param_caching' do
      ActiveSupport.on_load(:action_controller) do
        require 'action_param_caching/caching'
      end
    end
  end
end
