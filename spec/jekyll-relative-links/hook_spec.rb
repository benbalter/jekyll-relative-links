RSpec.describe JekyllRelativeLinks::Hook do
  let(:site) { fixture_site("site") }
  let(:page) { page_by_path(site, "page.md") }
  let(:html_page) { page_by_path(site, "html-page.html") }
  let(:another_page) { page_by_path(site, "another-page.md") }
  let(:subdir_page) { page_by_path(site, "subdir/page.md") }

  subject { described_class.new(site) }

  before(:each) do
    site.reset
    site.process
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

  context "generating" do
    it "converts relative links" do
      expect(page.content).to include(%(href="/another-page.html"))
    end

    it "converts relative links with permalinks" do
      expect(page.content).to include(%(href="/page-with-permalink/"))
    end

    it "converts relative links with leading slashes" do
      expect(page.content).to include(%(href="/another-page.html"))
    end

    it "converts pages in sub-directories" do
      expect(page.content).to include(%(href="/subdir/page.html"))
    end

    it "handles links within subdirectories" do
      expected = %(href="/subdir/another-subdir-page.html")
      expect(subdir_page.content).to include(expected)
    end

    it "handles relative links within subdirectories" do
      expected = %(href="/subdir/another-subdir-page.html")
      expect(subdir_page.content).to include(expected)
    end

    it "handles directory traversal" do
      expect(subdir_page.content).to include(%(href="/page.html"))
    end

    it "doesn't mangle HTML pages" do
      expect(page.content).to include(%(href="html-page.html"))
    end

    it "doesn't mangle invalid pages" do
      expect(page.content).to include(%(href="ghost-page.md"))
    end

    context "with a baseurl" do
      let(:site) { fixture_site("site", :baseurl => "/foo") }

      it "converts relative links" do
        expect(page.content).to include(%(href="/foo/another-page.html"))
      end

      it "handles links within subdirectories" do
        expected = %(href="/foo/subdir/another-subdir-page.html")
        expect(subdir_page.content).to include(expected)
      end

      it "handles relative links within subdirectories" do
        expected = %(href="/foo/subdir/another-subdir-page.html")
        expect(subdir_page.content).to include(expected)
      end

      it "handles directory traversal" do
        expect(subdir_page.content).to include(%(href="/foo/page.html"))
      end
    end
  end
end
