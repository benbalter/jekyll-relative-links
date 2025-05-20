# frozen_string_literal: true

module JekyllRelativeLinks
  module Filter
    # This filter processes HTML content that's already been converted by the markdownify
    # filter and updates any relative links to markdown files to point to their HTML equivalents.
    # Usage: {{ content | markdownify | rellinks }}
    def rellinks(html)
      return html if html.nil? || html.empty?
      return html if @context.registers[:site].nil?

      site = @context.registers[:site]
      page = @context.registers[:page]
      url_base = page ? File.dirname(page["path"].to_s) : ""

      html.gsub(%r!<a href="([^"]+\.md)(#([^"]+))?"!) do |match|
        relative_path = Regexp.last_match(1)
        fragment = Regexp.last_match(3) ? "##{Regexp.last_match(3)}" : ""

        if absolute_url?(relative_path) || !relative_path.end_with?(".md")
          match
        else
          path = path_from_root(relative_path, url_base)
          url = url_for_path(path, site)
          url ? "<a href=\"#{url}#{fragment}\"" : match
        end
      end
    end

    private

    def absolute_url?(string)
      return false unless string

      Addressable::URI.parse(string).absolute?
    rescue Addressable::URI::InvalidURIError
      false
    end

    def path_from_root(relative_path, url_base)
      is_absolute = relative_path.start_with? "/"

      relative_path.delete_prefix!("/")
      base = is_absolute ? "" : url_base
      absolute_path = File.expand_path(relative_path, base)
      absolute_path.sub(%r!\A#{Regexp.escape(Dir.pwd)}/!, "")
    end

    def url_for_path(path, site)
      path = CGI.unescape(path)
      potential_targets = site.pages + site.static_files + site.docs_to_write
      target = potential_targets.find { |p| p.relative_path.delete_prefix("/") == path }
      relative_url(target.url) if target&.url
    end
  end
end

Liquid::Template.register_filter(JekyllRelativeLinks::Filter)
