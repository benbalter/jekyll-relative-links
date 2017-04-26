module JekyllRelativeLinks
  class Generator < Jekyll::Generator
    attr_accessor :site

    # Use Jekyll's native relative_url filter
    include Jekyll::Filters::URLFilters

    LINK_TEXT_REGEX = %r!([^\]]+)!
    FRAGMENT_REGEX = %r!(#.+?)?!
    INLINE_LINK_REGEX = %r!\[#{LINK_TEXT_REGEX}\]\(([^\)]+?)#{FRAGMENT_REGEX}\)!
    REFERENCE_LINK_REGEX = %r!^\[#{LINK_TEXT_REGEX}\]: (.+?)#{FRAGMENT_REGEX}$!
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
        replace_relative_links!(page)
      end
    end

    def replace_relative_links!(page)
      url_base = File.dirname(page.path)

      page.content.gsub!(LINK_REGEX) do |original|
        link_type, link_text, relative_path, fragment = link_parts(Regexp.last_match)
        next original if fragment?(relative_path) || absolute_url?(relative_path)

        path = path_from_root(relative_path, url_base)
        url  = url_for_path(path)

        if url
          replacement_text(link_type, link_text, url, fragment)
        else
          original
        end
      end
    rescue ArgumentError => e
      raise e unless e.to_s.start_with?("invalid byte sequence in UTF-8")
    end

    private

    def link_parts(matches)
      link_type     = matches[2] ? :inline : :reference
      link_text     = matches[link_type == :inline ? 2 : 5]
      relative_path = matches[link_type == :inline ? 3 : 6]
      fragment      = matches[link_type == :inline ? 4 : 7]
      [link_type, link_text, relative_path, fragment]
    end

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
      target = potential_targets.find { |p| p.relative_path.sub(%r!\A/!, "") == path }
      relative_url(target.url) if target
    end

    def potential_targets
      @potential_targets ||= (site.pages + site.static_files)
    end

    def path_from_root(relative_path, url_base)
      relative_path.sub!(%r!\A/!, "")
      absolute_path = File.expand_path(relative_path, url_base)
      absolute_path.sub(%r!\A#{Regexp.escape(Dir.pwd)}/!, "")
    end

    def replacement_text(type, text, url, fragment = nil)
      url << fragment if fragment

      if type == :inline
        "[#{text}](#{url})"
      else
        "[#{text}]: #{url}"
      end
    end

    def absolute_url?(string)
      return unless string
      Addressable::URI.parse(string).absolute?
    rescue Addressable::URI::InvalidURIError
      nil
    end

    def fragment?(string)
      string && string.start_with?("#")
    end
  end
end
