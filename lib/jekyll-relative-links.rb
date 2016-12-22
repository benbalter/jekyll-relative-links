require "jekyll"
require "jekyll-relative-links/hook"
require "jekyll-relative-links/context"

module JekyllRelativeLinks
end

Jekyll::Hooks.register :site, :post_render do |site|
  JekyllRelativeLinks::Hook.new(site).convert
end
