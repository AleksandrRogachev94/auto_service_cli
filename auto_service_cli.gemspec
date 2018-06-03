# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'auto_service_cli/version'

Gem::Specification.new do |spec|
  spec.name          = "auto_service_cli"
  spec.version       = AutoServiceCLI::VERSION
  spec.date          = "2017-01-08"
  spec.authors       = ["Aleksandr Rogachev"]
  spec.email         = ["aleksandr.rogachev1994@gmail.com"]

  spec.summary       = %q{CLI for searching of auto service centers near your location.}
  spec.description   = %q{This CLI allows to find service centers near desired zip code (with sorting) and see details about each center.}
  spec.homepage      = "https://github.com/AleksandrRogachev94/auto_service_cli"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables << "auto_service"
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", "~> 1.8"
  spec.add_dependency "colorize", "~> 0.8"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.5"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.11"
end
