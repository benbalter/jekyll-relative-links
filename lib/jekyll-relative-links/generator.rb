module JekyllRelativeLinks
  class Generator < Jekyll::Generator
    attr_accessor :site

    # Use Jekyll's native relative_url filter
    include Jekyll::Filters::URLFilters

    INLINE_LINK_REGEX = %r!\[([^\]]+)\]\(([^\)]+)\)!
    REFERENCE_LINK_REGEX = %r!^\[([^\]]+)\]: (.*)$!
    LINK_REGEX = %r!(#{INLINE_LINK_REGEX}|#{REFERENCE_LINK_REGEX})!
    CONVERTER_CLASS = Jekyll::Converters::Markdown

    safe true
    priority :lowest

    def initialize(site)
      @site    = site
      @context = context
    end

    def generate(site)
      @site    = site
      @context = context

      site.pages.each do |page|
        next unless markdown_extension?(page.extname)
        url_base = File.dirname(page.path)

        page.content.gsub!(LINK_REGEX) do |original|
          link_type     = Regexp.last_match(2) ? :inline : :reference
          link_text     = Regexp.last_match(link_type == :inline ? 2 : 4)
          relative_path = Regexp.last_match(link_type == :inline ? 3 : 5)
          relative_path.sub!(%r!\A/!, "")
          url = url_for_path(path_from_root(relative_path, url_base))

          if url
            replacement_text(link_type, link_text, url)
          else
            original
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
