# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tileup/version'

Gem::Specification.new do |spec|
  spec.name        = 'moiristo-tileup'
  spec.version     = TileUp::VERSION
  spec.authors     = ['Reinier de Lange']
  spec.email       = 'rein@bookingexperts.nl'

  spec.summary     = 'Turn an image into an X,Y tile set for use with JS mapping libraries'
  spec.description = spec.summary
  spec.homepage    = 'http://github.com/rktjmp/tileup'
  spec.license     = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^test/})
  end

  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.10'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'mocha'

  spec.add_development_dependency 'rmagick', '~> 2.16'
  spec.add_development_dependency 'mini_magick', '~> 4.7'
end
