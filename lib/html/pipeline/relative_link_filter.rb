require "html/pipeline"
require "addressable"

module HTML
  class Pipeline
    # Relative link filter modifies relative links based on viewing location,
    # making it so these links lead to the correct desination no matter where
    # they are viewed from.
    #
    # Requires values passed in the context:
    #
    # base_url    - path that all links should be relative to
    # current_url - path where this content is being shown
    #                (e.g. "", "index.html", or "nested/dir")
    class RelativeLinkFilter < Filter
      def initialize(doc, context = nil, result = nil)
        super

        base = context[:base_url]
        # Base should always end in /
        base += "/" unless base.end_with?("/")
        @base_url = Addressable::URI.parse(base)
      end

      def call
        return doc unless should_process?

        doc.search("a").each do |node|
          apply_filter node, "href"
        end
        doc.search("img").each do |node|
          apply_filter node, "src"
        end
        doc.search("script").each do |node|
          apply_filter node, "src"
        end
        doc.search("link").each do |node|
          apply_filter node, "href"
        end

        doc
      end

      def should_process?
        context[:base_url] && context[:current_url]
      end

      def apply_filter(node, attribute)
        attr = node.attributes[attribute]
        if attr
          new_url = make_relative(attr.value)
          attr.value = new_url if new_url
        end
      end

      def make_relative(url)
        return unless url

        # Explicit protocol, e.g. https://example.com/
        return if url =~ %r!^[a-z][a-z0-9\+\.\-]+:!i
        # Protocol relative, e.g. //example.com/
        return if url.start_with?("//")
        # Hash, e.g #foobar
        return if url.start_with?("#")

        corrected_link(url)
      end

      private

      # Build a more absolute relative link
      #
      # link - original link
      def corrected_link(link)
        url = @base_url

        url = if link.start_with?(url.path)
                # Link already includes our base url
                url.join(link)
              elsif link.start_with?("/")
                # Make link relative to base
                url.join(link.sub("/", ""))
              else
                # Make link relative to base and current page
                url.join(context[:current_url]).join(link)
              end

        url.to_s
      end
    end
  end
end
