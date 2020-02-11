# frozen_string_literal: true

RSpec.describe JekyllRelativeLinks::Generator do
  let(:site_config) do
    overrides["relative_links"] = plugin_config if plugin_config
    overrides
  end
  let(:overrides) { {} }
  let(:plugin_config) { nil }
  let(:site) { fixture_site("site", site_config) }
  let(:page) { page_by_path(site, "page.md") }
  let(:html_page) { page_by_path(site, "html-page.html") }
  let(:another_page) { page_by_path(site, "another-page.md") }
  let(:subdir_page) { page_by_path(site, "subdir/page.md") }
  let(:post) { doc_by_path(site, "_posts/2016-01-01-test.md") }
  let(:subdir_post) { doc_by_path(site, "subdir/_posts/2016-01-01-test.md") }
  let(:item) { doc_by_path(site, "_items/some-item.md") }
  let(:item_2) { doc_by_path(site, "_items/some-subdir/another-item.md") }

  subject { described_class.new(site.config) }

  before(:each) do
    site.reset
    site.read
  end

  it "saves the config" do
    expect(subject.config).to eql(site.config)
  end

  context "detecting markdown" do
    before { subject.instance_variable_set "@site", site }

    it "knows when an extension is markdown" do
      expect(subject.send(:markdown_extension?, ".md")).to eql(true)
    end

    it "knows when an extension isn't markdown" do
      expect(subject.send(:markdown_extension?, ".html")).to eql(false)
    end

    it "knows the markdown converter" do
      expect(subject.send(:markdown_converter)).to be_a(Jekyll::Converters::Markdown)
    end
  end

  context "generating" do
    before { subject.generate(site) }

    it "converts relative links" do
      expect(page.content).to include("[Another Page](/another-page.html)")
    end

    it "converts relative links with permalinks" do
      expect(page.content).to include("[Page with permalink](/page-with-permalink/)")
    end

    it "converts relative links with leading slashes" do
      expect(page.content).to include("[Page with leading slash](/another-page.html)")
    end

    it "converts pages in sub-directories" do
      expect(page.content).to include("[Subdir Page](/subdir/page.html)")
    end

    it "handles links within subdirectories" do
      expected = "[Another subdir page](/subdir/another-subdir-page.html)"
      expect(subdir_page.content).to include(expected)
    end

    it "handles relative links within subdirectories" do
      expected = "[Relative subdir page](/subdir/another-subdir-page.html)"
      expect(subdir_page.content).to include(expected)
    end

    it "handles directory traversal" do
      expect(subdir_page.content).to include("[Dir traversal](/page.html)")
    end

    it "Handles HTML pages" do
      expect(page.content).to include("[HTML Page](/html-page.html)")
    end

    it "doesn't mangle invalid pages" do
      expect(page.content).to include("[Ghost page](ghost-page.md)")
    end

    it "handles links with nested square brackets" do
      expected = "[[A link with square brackets]](/another-page.html)"
      expect(page.content).to include(expected)
    end

    it "handles links with escaped nested square brackets" do
      expected = "[\\[A link with escaped square brackets\\]](/another-page.html)"
      expect(page.content).to include(expected)
    end

    it "handles links with a title" do
      expected = "[A link with a title](/another-page.html \"This is a link with a \\\"title\\\"\")"
      expect(page.content).to include(expected)
    end

    it "handles links with quotes in url fragment and title" do
      # single_quotes are valid in urls
      expected = "[Quotes in url & title](/another-page.html#'apostrophe' 'Quotes in url & title')"
      expect(page.content).to include(expected)
    end

    context "reference links" do
      it "handles reference links" do
        expect(page.content).to include("[reference]: /another-page.html")
      end

      it "handles indented reference links" do
        expect(page.content).to include("[indented-reference]: /another-page.html")
      end

      it "handles reference links with trailing whitespace" do
        expected = "[reference-with-whitespace]: /another-page.html"
        expect(page.content).to include(expected)
      end

      it "leaves newlines intact" do
        expected = "\n\nContent end\n\n[reference]: /another-page.html\n\n"
        expect(page.content).to include(expected)
      end

      it "handles reference links with titles" do
        expected = "[reference-with-title]: /another-page.html \"This is a reference with a title\""
        expect(page.content).to include(expected)
      end
    end

    context "with a baseurl" do
      let(:overrides) { { "baseurl" => "/foo" } }

      it "converts relative links" do
        expect(page.content).to include("[Another Page](/foo/another-page.html)")
      end

      it "handles links within subdirectories" do
        expected = "[Another subdir page](/foo/subdir/another-subdir-page.html)"
        expect(subdir_page.content).to include(expected)
      end

      it "handles relative links within subdirectories" do
        expected = "[Relative subdir page](/foo/subdir/another-subdir-page.html)"
        expect(subdir_page.content).to include(expected)
      end

      it "handles directory traversal" do
        expect(subdir_page.content).to include("[Dir traversal](/foo/page.html)")
      end
    end

    context "with a non-standard permalink structure" do
      let(:overrides) { { "permalink" => "/:year/:month/:title:output_ext" } }

      it "includes the extension" do
        expect(page.content).to include("[Another Page](/another-page.html)")
      end
    end

    context "linking to page fragments" do
      it "converts relative links" do
        expect(page.content).to include("[Fragment](/another-page.html#foo)")
      end

      it "converts relative links with permalinks" do
        expected = "[Fragment with permalink](/page-with-permalink/#foo)"
        expect(page.content).to include(expected)
      end

      it "converts reference links" do
        expected = "[reference-with-fragment]: /another-page.html#foo"
        expect(page.content).to include(expected)
      end

      it "converts reference links with brackets in fragment" do
        expected = "[reference-brackets]: /another-page.html#(bar)"
        expect(page.content).to include(expected)
      end

      it "converts multiple fragments in the same line" do
        expected_fst = "[A first fragment inline](/another-page.html#foo)"
        expected_snd = "[a second fragment in the same line](/page-with-permalink/#bar)"
        expect(page.content).to include(expected_fst)
        expect(page.content).to include(expected_snd)
      end
    end

    context "images" do
      it "handles images" do
        expect(subdir_page.content).to include("![image](/jekyll-logo.png)")
      end
    end

    context "disabled" do
      let(:plugin_config) { { "enabled" => false } }

      it "does not process pages when disabled" do
        expect(page.content).to include("[Another Page](another-page.md)")
      end
    end

    context "collections" do
      let(:plugin_config) { { "collections" => true } }
      let(:overrides) do
        {
          "collections" => {
            "items" => {
              "permalink" => "/items/:name/",
              "output"    => true,
            },
          },
        }
      end

      it "converts relative links from pages to posts" do
        expect(page.content).to include("[A post](/2016/01/01/test.html)")
      end

      it "converts relative links from posts to pages" do
        expect(post.content).to include("[Another Page](/another-page.html)")
      end

      it "converts relative links with permalinks from posts pages " do
        expect(post.content).to include("[Page with permalink](/page-with-permalink/)")
      end

      it "handles reference links from posts to pages" do
        expect(post.content).to include("[reference]: /another-page.html")
      end

      it "converts reference links" do
        expected = "[reference-with-fragment]: /another-page.html#foo"
        expect(post.content).to include(expected)
      end

      it "converts reference links with brackets in fragment" do
        expected = "[reference-brackets]: /another-page.html#(bar)"
        expect(post.content).to include(expected)
      end

      context "posts in subdirs" do
        it "converts relative links from pages to posts" do
          expect(page.content).to include("[Another post](/subdir/2016/01/01/test.html)")
        end

        it "converts relative links from posts to pages" do
          expect(subdir_post.content).to include("[Another Page](/another-page.html)")
        end

        it "converts relative links from posts to posts" do
          expect(subdir_post.content).to include("[Another Post](/2016/01/01/test.html)")
        end
      end

      context "items (with output)" do
        it "converts relative links from pages to items" do
          expect(page.content).to include("[An item](/items/some-item/)")
          expect(page.content).to include("[Another item](/items/another-item/)")
        end

        it "converts relative links from items to pages" do
          expect(item.content).to include("[Another Page](/another-page.html)")
          expect(item_2.content).to include("[Another Page](/another-page.html)")
        end

        it "converts relative links from posts to items" do
          expect(post.content).to include("[Item](/items/some-item/)")
        end

        it "converts relative links from items to posts" do
          expect(item.content).to include("[A post](/2016/01/01/test.html)")
        end
      end

      context "excludes" do
        let(:excludes) do
          [
            "another-page.md",
            "_posts/2016-01-01-test.md",
            "_items/some-subdir/another-item.md",
          ]
        end
        let(:plugin_config) { { "collections" => true, "exclude" => excludes } }

        context "pages" do
          it "includes included pages" do
            expect(page.content).to include("[Another Page](/another-page.html)")
          end

          it "excludes excluded pages" do
            expect(another_page.content).to include("[Page](page.md)")
          end
        end

        context "posts" do
          it "includes included posts" do
            expect(subdir_post.content).to include("[Another Page](/another-page.html)")
          end

          it "excludes excluded posts" do
            expect(post.content).to include("[Another Page](../another-page.md)")
          end
        end

        context "collections" do
          it "includes included documents" do
            expect(item.content).to include("[Another Page](/another-page.html)")
          end

          it "excludes excluded documents" do
            expect(item_2.content).to include("[Another Page](../../another-page.md)")
          end
        end
      end
    end
  end

  context "a page without content" do
    before { page_by_path(site, "page.md").content = nil }

    it "doesn't error out" do
      expect { subject.generate(site) }.to_not raise_error
    end
  end
end
