# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rhubarb/version'

Gem::Specification.new do |spec|
  spec.name          = "rhubarb"
  spec.version       = Rhubarb::VERSION
  spec.authors       = ["ellerynz"]
  spec.email         = ["hello@ellerynz.com"]
  spec.summary       = %q{Ruby on Rhubarb is a short, thick web framework.}
  spec.description   = %q{Ruby on Rhubarb is a short, thick web framework optimized for sugar or used in pies and desserts. It is hence useful as a cathartic in case of coders-block.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.4"
  spec.add_development_dependency "rack-test", "~> 0.7"
  spec.add_development_dependency "minitest", "~> 4.7"
  spec.add_runtime_dependency "rack", "~> 1.6"
  spec.add_runtime_dependency "erubis", "~> 2.7"
  spec.add_runtime_dependency "multi_json", "~> 1.12"
end
