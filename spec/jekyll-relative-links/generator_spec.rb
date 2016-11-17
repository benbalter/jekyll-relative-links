RSpec.describe JekyllRelativeLinks::Generator do
  let(:site) { fixture_site("site") }
  let(:page) { page_by_path(site, "page.md") }
  let(:html_page) { page_by_path(site, "html-page.html") }
  let(:another_page) { page_by_path(site, "another-page.md") }

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
      expect(subject.markdown_extension?(".md")).to eql(true)
    end

    it "knows when an extension isn't markdown" do
      expect(subject.markdown_extension?(".html")).to eql(false)
    end

    it "knows the markdown converter" do
      expect(subject.markdown_converter).to be_a(Jekyll::Converters::Markdown)
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

    it "doesn't mangle HTML pages" do
      expect(page.content).to include("[HTML Page](html-page.html)")
    end

    it "doesn't mangle invalid pages" do
      expect(page.content).to include("[Ghost page](ghost-page.md)")
    end

    context "with a baseurl" do
      let(:site) { fixture_site("site", baseurl: "/foo") }

      it "converts relative links" do
        expect(page.content).to include("[Another Page](/foo/another-page.html)")
      end
    end
  end
end
