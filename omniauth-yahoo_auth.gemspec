# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth/yahoo_auth/version'

Gem::Specification.new do |spec|
  spec.name          = "omniauth-yahoo_auth"
  spec.version       = Omniauth::YahooAuth::VERSION
  spec.authors       = ["Karan Pathak"]
  spec.email         = ["karan150394@gmail.com"]

  spec.summary       = "Yahoo OAuth2 Strategy for OmniAuth."
  spec.description   = "Yahoo OAuth2 Strategy. Supports OAuth 2.0 client-side flow. It lets you sign-in a rails app using yahoo login."
  spec.homepage      = "https://github.com/karan-pathak/omniauth-yahoo_auth"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'omniauth', '>= 1.1.1'
  spec.add_runtime_dependency 'omniauth-oauth2', '>= 1.5'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'byebug'
end
