module ActionParamCaching
  module Rails
    module ActionController
      attr_reader :action_cache_configs

      def cache_with_params(options = {})
        @action_cache_configs = {} if @action_cache_configs.nil?

        options[:on].each do |action|
          @action_cache_configs[action] = ActionParamCaching::ActionConfig.new(self.controller_path, action, options[:with_set_or_subset], options[:filter_starting_with]) unless @action_cache_configs[action]
        end

        options[:on].each do |action|
          config = @action_cache_configs[action]

          unless config.did_config_cache
            caches_action action, config.cache_args
            config.did_config_cache = true
          end
        end
      end
    end
  end
end