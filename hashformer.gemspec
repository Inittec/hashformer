# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hashformer/version'

Gem::Specification.new do |s|
  s.name          = 'hashformer'
  s.version       = Hashformer::VERSION
  s.authors       = ['Krzysztof Buszewicz']
  s.email         = ['krzysztof.buszewicz@gmail.com']
  s.summary       = 'Simple Hash Transformer'
  s.homepage      = ''
  s.license       = 'MIT'

  s.files         = `git ls-files -z`.split("\x0")
  s.require_paths = ['lib']

  s.add_development_dependency 'bundler', '~> 1.5'
  s.add_development_dependency 'rake'
end
