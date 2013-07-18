module ActionParamCaching
  class ActionConfig
    attr_reader :action, :valid_params, :filter_starting_with, :argz
    attr_accessor :did_config_cache

    def initialize(action, valid_params = [], filter_starting_with = nil)
      @action = action
      @valid_params = valid_params
      @filter_starting_with = filter_starting_with
      @did_config_cache = false
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

         @argz
    end

    def filtered_path_proc
      Proc.new { |request| params.delete_if { |k,v| k.to_s.start_with?(@filter_starting_with) }.to_query }
    end

    def path_proc
      Proc.new { |request| params.to_query }
    end

    def if_proc
      Proc.new { params.collect{|key, value| @valid_params.include?(key)}.all? }
    end
  end
end