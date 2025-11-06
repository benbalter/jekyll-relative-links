# frozen_string_literal: true

RSpec.describe JekyllRelativeLinks::Filter do
  let(:site) { fixture_site("site") }
  let(:page) { page_by_path(site, "page.md") }
  let(:subdir_page) { page_by_path(site, "subdir/page.md") }
  let(:filter) { make_filter }

  before do
    site.reset
    site.read
    site.liquid_renderer.reset
  end

  def make_filter
    @make_filter ||= begin
      filter_container = Class.new do
        include Jekyll::Filters::URLFilters
        include JekyllRelativeLinks::Filter
      end.new

      # Set up the context for the filter
      context = Liquid::Context.new({}, {}, {})
      context.registers[:site] = site
      context.registers[:page] = page
      filter_container.instance_variable_set(:@context, context)

      filter_container
    end
  end

  it "handles basic markdown links" do
    html = "<p><a href=\"another-page.md\">Link</a></p>"
    expected = "<p><a href=\"/another-page.html\">Link</a></p>"
    expect(filter.rellinks(html)).to eq(expected)
  end

  it "handles links with fragments" do
    html = "<p><a href=\"another-page.md#section\">Link with fragment</a></p>"
    expected = "<p><a href=\"/another-page.html#section\">Link with fragment</a></p>"
    expect(filter.rellinks(html)).to eq(expected)
  end

  it "doesn't affect links to non-markdown files" do
    html = "<p><a href=\"image.png\">Image</a></p>"
    expect(filter.rellinks(html)).to eq(html)
  end

  it "doesn't affect absolute URLs" do
    html = "<p><a href=\"https://example.com/page.md\">External</a></p>"
    expect(filter.rellinks(html)).to eq(html)
  end

  it "handles links from subdirectories" do
    set_subdir_context
    html = "<p><a href=\"page.md\">Link in subdir</a></p>"
    expected = "<p><a href=\"/subdir/page.html\">Link in subdir</a></p>"
    expect(filter.rellinks(html)).to eq(expected)
  end

  it "doesn't modify invalid links" do
    html = "<p><a href=\"ghost-page.md\">Ghost</a></p>"
    expect(filter.rellinks(html)).to eq(html)
  end

  it "handles links with spaces (URL-encoded)" do
    html = "<p><a href=\"page%20with%20space.md\">Link with space</a></p>"
    expected = "<p><a href=\"/page%20with%20space.html\">Link with space</a></p>"
    expect(filter.rellinks(html)).to eq(expected)
  end

  private

  def set_subdir_context
    context = Liquid::Context.new({}, {}, {})
    context.registers[:site] = site
    context.registers[:page] = subdir_page
    filter.instance_variable_set(:@context, context)
  end
end
