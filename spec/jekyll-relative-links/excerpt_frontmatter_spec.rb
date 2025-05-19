# frozen_string_literal: true

RSpec.describe JekyllRelativeLinks::Generator do
  subject { described_class.new(site.config) }

  let(:site) { fixture_site("excerpt-in-frontmatter") }
  let(:page) { page_by_path(site, "page-with-excerpt.md") }

  before do
    site.reset
    site.read
  end

  it "handles pages with excerpt in frontmatter" do
    expect { subject.generate(site) }.not_to raise_error
  end
end