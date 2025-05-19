# frozen_string_literal: true

RSpec.describe JekyllRelativeLinks::Generator do
  let(:generator) { described_class.new(site.config) }
  let(:site) { fixture_site("excerpt-in-frontmatter") }
  let(:page) { page_by_path(site, "page-with-excerpt.md") }

  before do
    site.reset
    site.read
    generator.generate(site)
  end

  context "with excerpt in frontmatter" do
    it "doesn't raise an error" do
      expect { generator.generate(site) }.not_to raise_error
    end

    it "preserves the frontmatter excerpt as a string" do
      expect(page.data["excerpt"]).to be_a(String)
      expect(page.data["excerpt"]).to eq("This is a custom excerpt")
    end

    it "still converts relative links in content" do
      expect(page.content).to include("[a link](/another-page.html)")
    end
  end
end
