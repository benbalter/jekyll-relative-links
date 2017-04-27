require "jekyll"
require "html/pipeline/relative_link_filter"
require "jekyll-relative-links/generator"
require "jekyll-relative-links/context"

module JekyllRelativeLinks
  class << self
    def relativize(doc)
      base_url = Addressable::URI.join(
        doc.site.config["url"].to_s,
        ensure_leading_slash(doc.site.config["baseurl"])
      ).normalize.to_s

      doc.output = filter(base_url, doc.url).call(doc.output)[:output].to_s
    end

    def filter(base_url, current_url)
      HTML::Pipeline.new(
        [HTML::Pipeline::RelativeLinkFilter],
        { :base_url => base_url, :current_url => current_url }
      )
    end

    # Public: Defines the conditions for a document to be relativizable.
    #
    # doc - the Jekyll::Document or Jekyll::Page
    #
    # Returns true if the doc is written & is HTML.
    def relativizable?(doc)
      (doc.is_a?(Jekyll::Page) || doc.write?) &&
        doc.output_ext == ".html" || (doc.permalink && doc.permalink.end_with?("/"))
    end

    def ensure_leading_slash(url)
      url[0] == "/" ? url : "/#{url}"
    end
  end
end

Jekyll::Hooks.register [:pages, :documents], :post_render do |doc|
  JekyllRelativeLinks.relativize(doc) if JekyllRelativeLinks.relativizable?(doc)
end
