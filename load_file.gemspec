# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'LoadFile/version'

Gem::Specification.new do |s|
  s.name          = "load_file"
  s.version       = LoadFile::VERSION
  s.authors       = ["Merlin Philipp"]
  s.email         = ["mphilipp@local"]
  s.summary       = %q{loads URI resources and unpacks archives if needed}
  s.description   = %q{ URI downloads resources. http basic auth is supported.
    downloads can be resumed using http-range header. ssl verification can be turned off
    Unarchive unpacks the resources if needed (currently only zip/gzip format)
  }
  s.homepage      = "http://github.com/merlin-p/load_file"
  s.license       = "MIT"

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_development_dependency 'bundler', '~> 1.7'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 3.0'

  s.add_runtime_dependency 'resque', '~> 1.25'
  s.add_runtime_dependency 'webmock', '~> 1.2'
end
