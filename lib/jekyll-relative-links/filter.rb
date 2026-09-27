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

      html.gsub(%r!<a href="([^"]+\.md)(#([^"]+))?"!) do |match|
        process_link(match, Regexp.last_match, url_base, site)
      end
    end

    def process_link(match, regex_match, url_base, site)
      relative_path = regex_match[1]
      fragment = regex_match[3] ? "##{regex_match[3]}" : ""

      return match if Resolver.absolute_url?(relative_path) || !relative_path.end_with?(".md")

      url = Resolver.url_for(relative_path, url_base, site)
      url ? "<a href=\"#{url}#{fragment}\"" : match
    end
  end
end

Liquid::Template.register_filter(JekyllRelativeLinks::Filter)
