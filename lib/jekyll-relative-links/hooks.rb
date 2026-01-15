# frozen_string_literal: true

module JekyllRelativeLinks
  # Register Jekyll hooks to process HTML output after conversion
  Jekyll::Hooks.register :pages, :post_render do |page|
    next unless JekyllRelativeLinks::Hooks.should_process?(page, page.site.config)

    page.output = JekyllRelativeLinks::Hooks.process_html_links(page.output, page, page.site)
  end

  Jekyll::Hooks.register :documents, :post_render do |document|
    next unless JekyllRelativeLinks::Hooks.should_process_document?(document, document.site.config)

    document.output = JekyllRelativeLinks::Hooks.process_html_links(document.output, document,
                                                                    document.site)
  end

  module Hooks
    CONVERTER_CLASS = Jekyll::Converters::Markdown
    CONFIG_KEY = "relative_links"
    ENABLED_KEY = "enabled"
    COLLECTIONS_KEY = "collections"

    def self.should_process?(page, config)
      return false if disabled?(config)
      return false unless markdown_extension?(page.extname, page.site)
      return false if excluded?(page, config, page.site)

      true
    end

    def self.should_process_document?(document, config)
      return false if disabled?(config)
      return false unless collections_enabled?(config)
      return false unless markdown_extension?(document.extname, document.site)
      return false if excluded?(document, config, document.site)

      true
    end

    def self.disabled?(config)
      config[CONFIG_KEY] && config[CONFIG_KEY][ENABLED_KEY] == false
    end

    def self.collections_enabled?(config)
      config[CONFIG_KEY] && config[CONFIG_KEY][COLLECTIONS_KEY] == true
    end

    def self.markdown_extension?(extension, site)
      converter = site.find_converter_instance(CONVERTER_CLASS)
      converter.matches(extension)
    end

    def self.excluded?(document, config, site)
      return false unless config[CONFIG_KEY] && config[CONFIG_KEY]["exclude"]

      entry_filter = if document.respond_to?(:collection)
                       document.collection.entry_filter
                     else
                       Jekyll::EntryFilter.new(site)
                     end

      entry_filter.glob_include?(config[CONFIG_KEY]["exclude"], document.relative_path)
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    def self.process_html_links(html, document, site)
      return html if html.nil? || html.empty?

      url_base = File.dirname(document.relative_path)
      potential_targets = site.pages + site.static_files + site.docs_to_write

      # Process <a href="*.md"> links that were added via includes
      html.gsub(%r!<a\s+([^>]*?\s+)?href="([^"]+\.md)(#[^"]*)?"\s*([^>]*)>!m) do |match|
        attributes_before = Regexp.last_match[1] || ""
        relative_path = Regexp.last_match[2]
        fragment = Regexp.last_match[3] || ""
        attributes_after = Regexp.last_match[4] || ""

        # Skip absolute URLs
        begin
          next match if Addressable::URI.parse(relative_path).absolute?
        rescue Addressable::URI::InvalidURIError
          next match
        end

        # Calculate path from root
        is_absolute = relative_path.start_with?("/")
        relative_path_clean = relative_path.delete_prefix("/")
        base = is_absolute ? "" : url_base
        absolute_path = File.expand_path(relative_path_clean, base)
        path = absolute_path.sub(%r!\A#{Regexp.escape(Dir.pwd)}/!, "")

        # Find the target page and get its URL
        path = CGI.unescape(path)
        target = potential_targets.find { |p| p.relative_path.delete_prefix("/") == path }

        if target&.url
          # Use Jekyll's URL
          url = target.url
          url = "/#{url}" unless url.start_with?("/")
          "<a #{attributes_before}href=\"#{url}#{fragment}\" #{attributes_after}>"
        else
          match
        end
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
  end
end
