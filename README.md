# ActionParamCaching [![Build Status](https://travis-ci.org/pennymac/action_param_caching.png?branch=master)](https://travis-ci.org/pennymac/action_param_caching)

Action param caching simplifies action caching based on parameter values. It allows you to quickly specify what actions you want to cache based on the parameters they are passed, the set of parameters you are interested in caching on, and an option prefix value for ignoring parameters that are designed to bust your cache.

## Installation

Add this line to your application's Gemfile:

    gem 'action_param_caching'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install action_param_caching

## Usage

 1. Enable rails caching (See rails docs).
 2. Require 'action_param_caching'
 3. Add 'extend ActionParamCaching::Rails::ActionController' to your controller
 4. Add the correct param cache statement to your controller.
    - Standard statement for full param caching:
      cache_with_params :on => [:index]
    - Cache on a set or subset
      cache_with_params :on => [:index], :with_set_or_subset => [:param1, :param2]
    - Ignore params with prefix
      cache_with_params :on => [:index], :filter_starting_with => '_'
    - Expiring Cache
      cache_with_params :on => [:index], :expires_in => 24.hours

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
