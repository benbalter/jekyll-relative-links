module JekyllRelativeLinks
  class Hook
    attr_accessor :site

    # Use Jekyll's native relative_url filter
    include Jekyll::Filters::URLFilters

    HREF_REGEX = %r!href=\"(.*?)\"!
    LINK_REGEX = %r!<a[^>]+#{HREF_REGEX}[^>]*>!
    CONVERTER_CLASS = Jekyll::Converters::Markdown

    def initialize(site)
      @site    = site
      @context = context
    end

    def convert
      @site    = site
      @context = context

      site.pages.each do |page|
        next unless markdown_extension?(page.extname)
        url_base = File.dirname(page.path)

        page.content.gsub!(LINK_REGEX) do |anchor|
          original_href = Regexp.last_match(1)
          original_href.sub!(%r!\A/!, "")
          url = url_for_path(path_from_root(original_href, url_base))

          if url
            anchor.sub!(HREF_REGEX, %(href="#{url}"))
          else
            anchor
          end
        end
      end
    end

    private

    def context
      JekyllRelativeLinks::Context.new(site)
    end

    def markdown_extension?(extension)
      markdown_converter.matches(extension)
    end

    def markdown_converter
      @markdown_converter ||= site.find_converter_instance(CONVERTER_CLASS)
    end

    def url_for_path(path)
      extension = File.extname(path)
      return unless markdown_extension?(extension)

      page = site.pages.find { |p| p.path == path }
      relative_url(page.url) if page
    end

    def path_from_root(relative_path, url_base)
      absolute_path = File.expand_path(relative_path, url_base)
      absolute_path.sub(%r!\A#{Dir.pwd}/!, "")
    end

    def replacement_text(type, text, url)
      if type == :inline
        "[#{text}](#{url})"
      else
        "[#{text}]: #{url}"
      end
    end
  end
end
