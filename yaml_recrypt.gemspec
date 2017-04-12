# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yaml_recrypt/version'

Gem::Specification.new do |spec|
  spec.name          = "yaml_recrypt"
  spec.version       = YamlRecrypt::VERSION
  spec.authors       = ["Geoff Williams"]
  spec.email         = ["geoff@geoffwilliams.me.uk"]
  spec.license       = "MIT"
  spec.summary       = %q{ Decrypt GPG encrypted yaml file keys and re-encrypt them using eyaml since GPG backend is EOLed (Puppet/Hiera) }
  spec.homepage      = "https://github.com/GeoffWilliams/yaml_recrypt"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "escort", "0.4.0"
  spec.add_dependency "gpgme", "2.0.12"
end
