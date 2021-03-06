# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'miss/operation/version'

Gem::Specification.new do |spec|
  spec.name          = "miss-operation"
  spec.version       = Miss::Operation::VERSION
  spec.authors       = ["Ralf Schmitz Bongiolo"]
  spec.email         = ["mrbongiolo@gmail.com"]

  spec.summary       = "Operate your stuff"
  spec.homepage      = "https://github.com/mrbongiolo/miss-operation"
  spec.license       = "MIT"

  spec.files         = Dir["README.md", "LICENSE.md", "Gemfile*", "Rakefile", "lib/**/*", "spec/**/*"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "dry-container"
  spec.add_runtime_dependency "dry-transaction"
  spec.add_runtime_dependency "dry-monads"
  spec.add_runtime_dependency "dry-matcher"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.10"
end
