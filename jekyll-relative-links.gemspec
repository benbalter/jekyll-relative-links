# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("lib", __dir__)
require "jekyll-relative-links/version"

Gem::Specification.new do |s|
  s.name          = "jekyll-relative-links"
  s.version       = JekyllRelativeLinks::VERSION
  s.authors       = ["Ben Balter"]
  s.email         = ["ben.balter@github.com"]
  s.homepage      = "https://github.com/benbalter/jekyll-relative-links"
  s.summary       = "A Jekyll plugin to convert relative links to markdown files " \
                    "to their rendered equivalents.\n"

  s.files         = `git ls-files app lib`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ["lib"]
  s.license       = "MIT"

  s.add_dependency "jekyll", ">= 3.3", "< 5.0"
  s.add_development_dependency "kramdown-parser-gfm", "~> 1.0"
  s.add_development_dependency "rspec", "~> 3.5"
  s.add_development_dependency "rubocop", "~> 1.0"
  s.add_development_dependency "rubocop-factory_bot", "~> 2.22.0"
  s.add_development_dependency "rubocop-jekyll", "~> 0.10"
  s.add_development_dependency "rubocop-performance", "~> 1.5"
  s.add_development_dependency "rubocop-rspec", "~> 2.0.0"
end
