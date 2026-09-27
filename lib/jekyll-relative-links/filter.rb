# frozen_string_literal: true

module JekyllRelativeLinks
  module Filter
    # This filter processes HTML content that's already been converted by the markdownify
    # filter and updates any relative links to markdown files to point to their HTML equivalents.
    # Usage: {{ content | markdownify | rellinks }}
    def rellinks(html)
      return html if html.nil? || html.empty?
      return html if @context.registers[:site].nil?

      process_links(html, @context.registers[:site])
    end

    def process_links(html, site)
      page = @context.registers[:page]
      url_base = page ? File.dirname(page["path"].to_s) : ""

      Resolver.rewrite_html_links(html, url_base, site)
    end
  end
end

Liquid::Template.register_filter(JekyllRelativeLinks::Filter)
