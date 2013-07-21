require 'spec_helper'

module ActionParamCaching
  describe ActionConfig do
    context "in order to track the cache configuration of an action" do
      it "is initialized with valid params, an action, and a prefix filter" do
        cache_config = ActionParamCaching::ActionConfig.new("some_controller", :index,[:id, :name, :amount], '_')
        cache_config.action.should == :index
        cache_config.valid_params.should == [:id, :name, :amount, :controller, :action, :format]
        cache_config.filter_starting_with.should == '_'
      end

      it "sets the correct default values for valid params and prefix filters" do
        cache_config = ActionParamCaching::ActionConfig.new("some_controller", :index)
        cache_config.action.should == :index
        cache_config.valid_params.should == nil
        cache_config.filter_starting_with.should == '_'
      end

      it "tracks if a cache has been configured" do
        cache_config = ActionParamCaching::ActionConfig.new("some_controller", :index)
        cache_config.did_config_cache.should be_false
        cache_config.did_config_cache = true
        cache_config.did_config_cache.should be_true
      end
    end

    context "when generating action cache arguments" do
      it "has an if condition when you specify valid params" do
        cache_config = ActionParamCaching::ActionConfig.new("some_controller", :index,[:id, :name, :amount], '_')
        cache_args = cache_config.cache_args
        cache_args[:if].should be
      end

      it "does not have an if condition if you don't specify valid params" do
        cache_config = ActionParamCaching::ActionConfig.new("some_controller",:index)
        cache_args = cache_config.cache_args
        cache_args[:if].should be_nil
      end

      it "has a the correct cache path when stripping params with a prefix" do
        cache_config = ActionParamCaching::ActionConfig.new("some_controller", :index,[:id, :name, :amount], '_')
        request = mock
        request.stubs(:params).returns( {:_remove_me => true, :controller => "some_controller", :action => :index, :format => 'json'} )
        cache_args = cache_config.cache_args
        proc = cache_args[:cache_path]
        proc.call(request).should == {:controller => "some_controller", :action => :index, :format => 'json'}.to_query
      end

      it "has a the correct cache path under normal conditions" do
        cache_config = ActionParamCaching::ActionConfig.new("some_controller", :index,[:id, :name, :amount])
        cache_args = cache_config.cache_args
        request = mock
        request.stubs(:params).returns( {:_remove_me => false, :controller => "some_controller", :action => :index, :format => 'json'} )
        proc = cache_args[:cache_path]
        proc.call(request).should == {:controller => "some_controller", :action => :index, :format => 'json'}.to_query
      end

      it "does not have a if argument if the valid params are empty" do
        cache_config = ActionParamCaching::ActionConfig.new("some_controller", :index)
        cache_args = cache_config.cache_args
        cache_args[:if].should be_nil
      end

      it "does have an if argument that returns true if the params are a subset of the valid params" do
        cache_config = ActionParamCaching::ActionConfig.new("some_controller", :index,[:id, :name, :amount])
        cache_args = cache_config.cache_args
        request = mock
        request.stubs(:params).returns( {:id => 23, :name => "test", :controller => "some_controller", :action => :index, :format => 'json'} )
        proc = cache_args[:if]
        proc.call(request).should be_true
      end

      it "does have an if argument that returns false if the params are not a subset of the valid params" do
        cache_config = ActionParamCaching::ActionConfig.new("some_controller", :index,[:id, :name, :amount])
        cache_args = cache_config.cache_args
        request = mock
        request.stubs(:params).returns( {:id => 23, :name => "test", :not => "valid", :controller => "some_controller", :action => :index, :format => 'json'} )
        proc = cache_args[:if]
        proc.call(request).should be_false
      end
    end
  end
end