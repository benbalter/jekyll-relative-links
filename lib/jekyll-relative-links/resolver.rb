# frozen_string_literal: true

require "cgi"

module JekyllRelativeLinks
  # Resolves a relative link to a Markdown file into the URL of the page,
  # static file or document it points at. Shared by the generator, the
  # rellinks filter and the post_render hooks so all three agree.
  module Resolver
    # Exposes Jekyll's URL filters (e.g. relative_url) outside of Liquid
    class UrlFilter
      include Jekyll::Filters::URLFilters

      def initialize(site)
        @context = JekyllRelativeLinks::Context.new(site)
      end
    end

    class << self
      # Returns the URL (including the site's baseurl) that `relative_path`,
      # linked from a file in `url_base`, resolves to, or nil if there's no
      # such page, static file or document.
      def url_for(relative_path, url_base, site)
        path   = path_from_root(CGI.unescape(relative_path), url_base)
        target = targets_by_path(site)[path]
        url_filter(site).relative_url(target.url) if target&.url
      end

      def absolute_url?(string)
        return false unless string

        Addressable::URI.parse(string).absolute?
      rescue Addressable::URI::InvalidURIError
        false
      end

      def path_from_root(relative_path, url_base)
        is_absolute   = relative_path.start_with?("/")
        base          = is_absolute ? "" : url_base
        absolute_path = File.expand_path(relative_path.delete_prefix("/"), base)
        absolute_path.sub(%r!\A#{Regexp.escape(Dir.pwd)}/!, "")
      end

      # Index potential link targets by relative path so each lookup is O(1).
      # The index is built once per site and dropped on every reset and
      # before rendering, so rebuilds (e.g. `jekyll serve`) and pages added by
      # other generators are picked up. If two targets share a path, the
      # first one wins.
      def targets_by_path(site)
        reset unless @site.equal?(site)
        @site = site
        @targets_by_path ||= potential_targets(site).each_with_object({}) do |target, index|
          key = target.relative_path.delete_prefix("/")
          index[key] = target unless index.key?(key)
        end
      end

      def reset
        @site = nil
        @targets_by_path = nil
        @url_filter = nil
      end

      private

      def potential_targets(site)
        site.pages + site.static_files + site.docs_to_write
      end

      def url_filter(site)
        targets_by_path(site)
        @url_filter ||= UrlFilter.new(site)
      end
    end
  end

  Jekyll::Hooks.register(:site, :after_reset) { Resolver.reset }
  Jekyll::Hooks.register(:site, :pre_render) { Resolver.reset }
end
