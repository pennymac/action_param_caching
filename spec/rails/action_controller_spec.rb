require 'spec_helper'

class TestController < ActionController::Base
  def self.caches_action(action, args)
  end

  def self.controller_path
    "some_controller"
  end
end

RSpec.describe TestController do
  it "provides param configuration for action caching" do
    expect(TestController).to respond_to(:action_cache_configs)
  end

  it "provides a means to configure caching for mutiple actions with one statement" do
    TestController.cache_with_params :on => [:test1]

    expect(TestController.action_cache_configs[:test1].action).to eq :test1
  end

  it "provided a means to set a set or subset or params to cache on" do
    TestController.cache_with_params :on => [:test2], :with_set_or_subset => [:param1, :param2]

    expect(TestController.action_cache_configs[:test2].valid_params).to eq [:param1, :param2, :controller, :action, :format]
  end

  it "provides a means to filter params that have a prefix" do
    TestController.cache_with_params :on => [:test3], :filter_starting_with => '_'

    expect(TestController.action_cache_configs[:test3].filter_starting_with).to eq '_'
  end

  it "configures the cache actions using the specified params" do
    TestController.expects(:caches_action)

    TestController.cache_with_params :on => [:test4], :filter_starting_with => '_', :with_set_or_subset => [:param1, :param2]
  end
end
