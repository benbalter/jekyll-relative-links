module JekyllRelativeLinks
  class Generator < Jekyll::Generator
    attr_accessor :site

    LINK_REGEX = %r!\[([^\]]+)\]\(([^\)]+)\)!
    CONVERTER_CLASS = Jekyll::Converters::Markdown

    safe true
    priority :lowest

    def initialize(site)
      @site = site
    end

    def generate(site)
      @site = site
      
      site.pages.each do |page|
        next unless markdown_extension?(page.extname)
        url_base = File.dirname(page.path)

        page.content.gsub!(LINK_REGEX) do |original|
          link_text      = Regexp.last_match(1)
          relative_path  = Regexp.last_match(2).sub(%r!\A/!, "")
          absolute_path  = File.expand_path(relative_path, url_base)
          path_from_root = absolute_path.sub(%r!\A#{Dir.pwd}/!, "")

          if (url = url_for_path(path_from_root))
            "[#{link_text}](#{site.baseurl}#{url})"
          else
            original
          end
        end
      end
    end

    private

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
      page.url if page
    end
  end
end
