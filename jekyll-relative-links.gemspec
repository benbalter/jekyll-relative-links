# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'jekyll-relative-links/version'

Gem::Specification.new do |s|
  s.name          = "jekyll-relative-links"
  s.version       = JekyllRelativeLinks::VERSION
  s.authors       = ["Ben Balter"]
  s.email         = ["ben.balter@github.com"]
  s.homepage      = "https://github.com/benbalter/jekyll-relative-links"
  s.summary       = "A Jekyll plugin to convert relative links to markdown files to their rendered equivalents.
"

  s.files         = `git ls-files app lib`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.license       = "MIT"

  s.add_dependency "jekyll", "~> 3.3"
  s.add_dependency "html-pipeline"
  s.add_dependency "addressable"
  s.add_development_dependency "rubocop", "~> 0.43"
  s.add_development_dependency "rspec", "~> 3.5"
end
