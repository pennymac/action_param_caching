require 'spec_helper'

module ActionParamCaching
  describe ActionConfig do
    context "in order to track the cache configuration of an action" do
      it "is initialized with valid params, an action, and a prefix filter" do
        cache_config = ActionParamCaching::ActionConfig.new(:index,[:id, :name, :amount], '_')
        cache_config.action.should == :index
        cache_config.valid_params.should == [:id, :name, :amount]
        cache_config.filter_starting_with.should == '_'
      end

      it "sets the correct default values for valid params and prefix filters" do
        cache_config = ActionParamCaching::ActionConfig.new(:index)
        cache_config.action.should == :index
        cache_config.valid_params.should == []
        cache_config.filter_starting_with.should be_nil
      end

      it "tracks if a cache has been configured" do
        cache_config = ActionParamCaching::ActionConfig.new(:index)
        cache_config.did_config_cache.should be_false
        cache_config.did_config_cache = true
        cache_config.did_config_cache.should be_true
      end
    end

    context "when generating action cache arguments" do
      it "has an if condition when you specify valid params" do
        cache_config = ActionParamCaching::ActionConfig.new(:index,[:id, :name, :amount], '_')
        cache_args = cache_config.cache_args
        cache_args[:if].should be
      end

      it "does not have an if condition if you don't specify valid params" do
        cache_config = ActionParamCaching::ActionConfig.new(:index)
        cache_args = cache_config.cache_args
        cache_args[:if].should be_nil
      end

      it "has a the correct cache path when stripping params with a prefix" do
        cache_config = ActionParamCaching::ActionConfig.new(:index,[:id, :name, :amount], '_')


        cache_config.stubs(:params).returns( {:_remove_me => true} )
        cache_args = cache_config.cache_args
        proc = cache_args[:cache_path]
        proc.call(nil).should == ""
      end

      it "has a the correct cache path under normal conditions" do
        cache_config = ActionParamCaching::ActionConfig.new(:index,[:id, :name, :amount])
        cache_args = cache_config.cache_args
        cache_config.stubs(:params).returns( {:_remove_me => false} )
        proc = cache_args[:cache_path]
        proc.call(nil).should == cache_config.params.to_query
      end

      it "does not have a if argument if the valid params are empty" do
        cache_config = ActionParamCaching::ActionConfig.new(:index)
        cache_args = cache_config.cache_args
        cache_args[:if].should be_nil
      end

      it "does have an if argument that returns true if the params are a subset of the valid params" do
        cache_config = ActionParamCaching::ActionConfig.new(:index,[:id, :name, :amount])
        cache_args = cache_config.cache_args
        cache_config.stubs(:params).returns( {:id => 23, :name => "test"} )
        proc = cache_args[:if]
        proc.call.should be_true
      end

      it "does have an if argument that returns false if the params are not a subset of the valid params" do
        cache_config = ActionParamCaching::ActionConfig.new(:index,[:id, :name, :amount])
        cache_args = cache_config.cache_args
        cache_config.stubs(:params).returns( {:id => 23, :name => "test", :not => "valid"} )
        proc = cache_args[:if]
        proc.call.should be_false
      end
    end
  end
end