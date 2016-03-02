require 'spec_helper'

module ActionParamCaching
  describe ActionConfig do
    context "in order to track the cache configuration of an action" do
      it "is initialized with valid params, an action, and a prefix filter" do
        cache_config = ActionParamCaching::ActionConfig.new("some_controller", :index,[:id, :name, :amount], '_')

        expect(cache_config.action).to eq :index
        expect(cache_config.valid_params).to eq [:id, :name, :amount, :controller, :action, :format]
        expect(cache_config.filter_starting_with).to eq '_'
      end

      it "sets the correct default values for valid params and prefix filters" do
        cache_config = ActionParamCaching::ActionConfig.new("some_controller", :index)

        expect(cache_config.action).to eq :index
        expect(cache_config.valid_params).to eq nil
        expect(cache_config.filter_starting_with).to eq '_'
      end

      it "tracks if a cache has been configured" do
        cache_config = ActionParamCaching::ActionConfig.new("some_controller", :index)

        expect(cache_config.did_config_cache).to eq false

        cache_config.did_config_cache = true

        expect(cache_config.did_config_cache).to eq true
      end
    end

    context "when generating action cache arguments" do
      it "has an if condition when you specify valid params" do
        cache_config = ActionParamCaching::ActionConfig.new("some_controller", :index,[:id, :name, :amount], '_')
        cache_args = cache_config.cache_args
        expect(cache_args[:if]).not_to eq nil
      end

      it "does not have an if condition if you don't specify valid params" do
        cache_config = ActionParamCaching::ActionConfig.new("some_controller",:index)
        cache_args = cache_config.cache_args

        expect(cache_args[:if]).to eq nil
      end

      it "has a the correct cache path when stripping params with a prefix" do
        cache_config = ActionParamCaching::ActionConfig.new("some_controller", :index,[:id, :name, :amount], '_')
        request = mock
        request.stubs(:params).returns( {:_remove_me => true, :controller => "some_controller", :action => :index, :format => 'json'} )
        cache_args = cache_config.cache_args
        proc = cache_args[:cache_path]
        expect(proc.call(request)).to eq({:controller => "some_controller", :action => :index, :format => 'json'}.to_query)
      end

      it "has a the correct cache path under normal conditions" do
        cache_config = ActionParamCaching::ActionConfig.new("some_controller", :index,[:id, :name, :amount])
        cache_args = cache_config.cache_args
        request = mock
        request.stubs(:params).returns( {:_remove_me => false, :controller => "some_controller", :action => :index, :format => 'json'} )
        proc = cache_args[:cache_path]
        expect(proc.call(request)).to eq({:controller => "some_controller", :action => :index, :format => 'json'}.to_query)
      end

      it "does not have a if argument if the valid params are empty" do
        cache_config = ActionParamCaching::ActionConfig.new("some_controller", :index)
        cache_args = cache_config.cache_args
        expect(cache_args[:if]).to be_nil
      end

      it "does have an if argument that returns true if the params are a subset of the valid params" do
        cache_config = ActionParamCaching::ActionConfig.new("some_controller", :index,[:id, :name, :amount])
        cache_args = cache_config.cache_args
        request = mock
        request.stubs(:params).returns( {:id => 23, :name => "test", :controller => "some_controller", :action => :index, :format => 'json'} )
        proc = cache_args[:if]
        expect(proc.call(request)).to eq true
      end

      it "does have an if argument that returns false if the params are not a subset of the valid params" do
        cache_config = ActionParamCaching::ActionConfig.new("some_controller", :index,[:id, :name, :amount])
        cache_args = cache_config.cache_args
        request = mock
        request.stubs(:params).returns( {:id => 23, :name => "test", :not => "valid", :controller => "some_controller", :action => :index, :format => 'json'} )
        proc = cache_args[:if]
        expect(proc.call(request)).to eq false
      end
      
      it "adds expires in parameter to action arguments" do
        cache_config = ActionParamCaching::ActionConfig.new("some_controller", :index, [:id, :name, :amount], nil, 24.hours)
        cache_args = cache_config.cache_args
        request = mock
        request.stubs(:params).returns( {:id => 23, :name => "test", :not => "valid", :controller => "some_controller", :action => :index, :format => 'json', :expires_in => 24.hours} )

        expect(cache_args[:expires_in]).to eq 24.hours
      end
    end
  end
end
