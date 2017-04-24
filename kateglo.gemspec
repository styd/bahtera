# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kateglo/version'

Gem::Specification.new do |s|
  s.name          = "kateglo"
  s.version       = Kateglo::VERSION
  s.authors       = ["Adrian Setyadi", "Adinda Praditya"]
  s.email         = ["a.styd@yahoo.com", "apraditya@gmail.com"]
  s.description   = %q{The unofficial Ruby library for accessing Kateglo API, an online dictionary, thesaurus and glossarium for bahasa Indonesia}
  s.summary       = %q{Kateglo Ruby gem}
  s.homepage      = "https://github.com/styd/kateglo"

  s.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  s.bindir        = "exe"
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]


  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'

  s.add_runtime_dependency 'addressable'
  s.add_runtime_dependency 'multi_json'

end
