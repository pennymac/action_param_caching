# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'action_param_caching/version'

Gem::Specification.new do |spec|
  spec.name          = "action_param_caching"
  spec.version       = ActionParamCaching::VERSION
  spec.authors       = ["cparratto"]
  spec.email         = ["chris.parratto@pnmac.com"]
  spec.description   = %q{Parameterized caching for ActionControllers}
  spec.summary       = %q{Allows for parameterized caching for action controllers.}
  spec.homepage      = "https://github.com/pennymac/action_param_caching"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "actionpack-action_caching", "1.1.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "activesupport"
  spec.add_development_dependency "i18n"
end
