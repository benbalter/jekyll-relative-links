# frozen_string_literal: true

RSpec.describe JekyllRelativeLinks::Resolver do
  let(:site) { fixture_site("site") }

  before do
    site.reset
    site.read
  end

  describe ".url_for" do
    it "returns nil for a root-relative link starting with /~" do
      expect { described_class.url_for("/~nonexistent/example.pdf", ".", site) }.not_to raise_error
      expect(described_class.url_for("/~nonexistent/example.pdf", ".", site)).to be_nil
    end

    it "returns nil for a relative link starting with ~" do
      expect { described_class.url_for("~nonexistent/example.pdf", ".", site) }.not_to raise_error
      expect(described_class.url_for("~nonexistent/example.pdf", ".", site)).to be_nil
    end

    it "returns nil for a link that is just ~" do
      expect(described_class.url_for("~", "subdir", site)).to be_nil
    end

    it "treats an empty url_base like the site root" do
      expect(described_class.url_for("subdir/page.md", "", site)).to eql("/subdir/page.html")
    end

    it "still resolves ../ links" do
      url = described_class.url_for("../another-page.md", "subdir", site)
      expect(url).to eql("/another-page.html")
    end
  end
end
