# frozen_string_literal: true

RSpec.describe JekyllRelativeLinks::Generator do
  let(:site) { fixture_site("site-with-includes") }
  let(:index_page) { page_by_path(site, "index.md") }

  before do
    site.reset
    site.read
    described_class.new(site.config).generate(site)
    site.render
  end

  it "converts relative links in the main content" do
    # After rendering, the link should be converted in the HTML output
    expect(index_page.output).to include('href="/target.html"')
  end

  it "converts relative links in included content" do
    # This is the failing test - included content is not processed
    # The include should have its link converted too
    # Currently fails: shows href="target.md" instead of href="/target.html"
    expect(index_page.output).to include('href="/target.html"').twice
  end
end
