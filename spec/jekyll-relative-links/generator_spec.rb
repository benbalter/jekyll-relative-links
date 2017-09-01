RSpec.describe JekyllRelativeLinks::Generator do
  let(:config) { {} }
  let(:overrides) { { "jekyll_relative_links" => config } }
  let(:site) { fixture_site("site", overrides) }
  let(:page) { page_by_path(site, "page.md") }
  let(:html_page) { page_by_path(site, "html-page.html") }
  let(:another_page) { page_by_path(site, "another-page.md") }
  let(:subdir_page) { page_by_path(site, "subdir/page.md") }
  let(:post) { page_by_path(site, "_posts/2017-01-01-post.md") }
  subject { described_class.new(site) }

  before(:each) do
    site.reset
    site.read
  end

  it "saves the site" do
    expect(subject.site).to eql(site)
  end

  context "detecting markdown" do
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

  context "collections" do
    context "with no collections specfied" do
      let(:config) { { "collections" => [] } }

      it "doesn't process posts" do
        expect(subject.send(:process_collection?, site.collections.first)).to be_falsy
      end
    end

    context "with posts specified" do
      let(:config) { { "collections" => ["posts"] } }

      it "processes posts" do
        expect(subject.send(:process_collection?, site.collections.first)).to be_truthy
      end
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

    it "rewrites links to documents" do
      expect(page.content).to include("[A Post](/2017/01/01/post.html)")
    end

    context "reference links" do
      it "handles reference links" do
        expect(page.content).to include("[reference]: /another-page.html")
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

    context "without the posts collection" do
      it "doesn't mangle posts" do
        expect(post.content).to include("[Page](../page.md)")
      end
    end

    context "with the posts collection" do
      let(:config) { { "collections" => ["posts"] } }

      it "converts links in posts" do
        expect(post.content).to include("[Page](/page.html)")
      end
    end
  end
end
