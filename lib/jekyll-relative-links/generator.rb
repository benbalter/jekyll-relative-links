module JekyllRelativeLinks
  class Generator < Jekyll::Generator
    attr_accessor :site

    # Use Jekyll's native relative_url filter
    include Jekyll::Filters::URLFilters

    FRAGMENT_REGEX = %r!(#.+?)?!
    INLINE_LINK_REGEX = %r!\]\(([^\)]+?)#{FRAGMENT_REGEX}\)!
    REFERENCE_LINK_REGEX = %r!\]: (.+?)#{FRAGMENT_REGEX}\s*$!
    LINK_REGEX = %r!(#{INLINE_LINK_REGEX}|#{REFERENCE_LINK_REGEX})!
    CONVERTER_CLASS = Jekyll::Converters::Markdown
    CONFIG_KEY = "relative_links".freeze
    ENABLED_KEY = "enabled".freeze
    COLLECTIONS_KEY = "collections".freeze

    safe true
    priority :lowest

    def initialize(site)
      @site    = site
      @context = context
    end

    def generate(site)
      @site    = site
      @context = context
      return if disabled?

      documents = site.pages
      documents = site.pages + site.docs_to_write if collections?

      documents.each do |document|
        next unless markdown_extension?(document.extname)
        replace_relative_links!(document)
      end
    end

    def replace_relative_links!(document)
      url_base = File.dirname(document.relative_path)

      document.content.gsub!(LINK_REGEX) do |original|
        link_type, relative_path, fragment = link_parts(Regexp.last_match)
        next original if fragment?(relative_path) || absolute_url?(relative_path)

        path = path_from_root(relative_path, url_base)
        url  = url_for_path(path)

        if url
          replacement_text(link_type, url, fragment)
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
      relative_path = matches[link_type == :inline ? 2 : 4]
      fragment      = matches[link_type == :inline ? 3 : 5]
      [link_type, relative_path, fragment]
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
      relative_url(target.url) if target && target.url
    end

    def potential_targets
      @potential_targets ||= site.pages + site.static_files + site.docs_to_write
    end

    def path_from_root(relative_path, url_base)
      relative_path.sub!(%r!\A/!, "")
      absolute_path = File.expand_path(relative_path, url_base)
      absolute_path.sub(%r!\A#{Regexp.escape(Dir.pwd)}/!, "")
    end

    def replacement_text(type, url, fragment = nil)
      url << fragment if fragment

      if type == :inline
        "](#{url})"
      else
        "]: #{url}"
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

    def option(key)
      site.config[CONFIG_KEY] && site.config[CONFIG_KEY][key]
    end

    def disabled?
      option(ENABLED_KEY) == false
    end

    def collections?
      option(COLLECTIONS_KEY) == true
    end
  end
end
