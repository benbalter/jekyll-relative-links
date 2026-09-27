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

    MARKDOWN_LINK_IN_HTML = Resolver::MARKDOWN_LINK_IN_HTML

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

    # Rewrites <a href="*.md"> links in the output, e.g. ones added by includes
    def self.process_html_links(html, document, site)
      return html if html.nil? || html.empty?

      Resolver.rewrite_html_links(html, File.dirname(document.relative_path), site)
    end
  end
end
