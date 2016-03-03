module ActionParamCaching
  module Caching
    extend ActiveSupport::Concern

    module ClassMethods
      attr_reader :action_cache_configs

      def cache_with_params(options = {})
        @action_cache_configs = {} if @action_cache_configs.nil?

        options[:on].each do |action|
          @action_cache_configs[action] = Config.new(self.controller_path, action, options[:with_set_or_subset], options[:filter_starting_with], options[:expires_in]) unless @action_cache_configs[action]
        end

        options[:on].each do |action|
          config = @action_cache_configs[action]

          unless config.did_config_cache
            caches_action action, config.cache_args
            config.did_config_cache = true
          end
        end

        if options[:expires_in]
          caches_action :expires_in => options[:expires_in]
        end
      end
    end

    class Config
      attr_reader :action, :valid_params, :filter_starting_with, :argz, :expires_in
      attr_accessor :did_config_cache

      def self.store_lookup(controller, action, config)
         @lookup = {} if @lookup.nil?
         @lookup[controller] = {} if @lookup[controller].nil?
         @lookup[controller][action] = config
      end

      def self.lookup
        @lookup
      end

      def initialize(controller_path, action, valid_params = [], filter_starting_with = nil, expires_in = nil)
        @action = action
        if valid_params and !valid_params.empty?
          @valid_params = valid_params
          @valid_params << :controller << :action << :format
        end
        @filter_starting_with = filter_starting_with
        @filter_starting_with ||= '_'
        @did_config_cache = false
        @expires_in = expires_in

        Config.store_lookup(controller_path, action, self)
      end

      def cache_args
        @argz = {}

        if @valid_params && @valid_params.any?
          @argz[:if] = self.if_proc
        end

        if @filter_starting_with
          @argz[:cache_path] = self.filtered_path_proc
        else
          @argz[:cache_path] = self.path_proc
        end

        if @expires_in
          @argz[:expires_in] = self.expires_in
        end

        @argz
      end

      def filtered_path_proc
        Proc.new { |request|
          request.params.delete_if { |k,v| k.to_s.start_with?(Config.lookup[request.params[:controller]][request.params[:action].to_sym].filter_starting_with) }.to_query
        }
      end

      def path_proc
        Proc.new { |request| request.params.to_query }
      end

      def if_proc
        Proc.new { |request|
          request.params.collect{ |key, value|
            Config.lookup[request.params[:controller]][request.params[:action].to_sym].valid_params.include?(key.to_sym) ||
            key.to_s.start_with?(Config.lookup[request.params[:controller]][request.params[:action].to_sym].filter_starting_with)}.all?
        }
      end
    end
  end
end
