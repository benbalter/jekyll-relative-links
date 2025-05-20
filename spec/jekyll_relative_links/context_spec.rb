# frozen_string_literal: true

RSpec.describe JekyllRelativeLinks::Context do
  subject(:context) { described_class.new(site) }

  let(:site) { fixture_site("site") }

  it "stores the site" do
    expect(context.site).to eql(site)
  end

  it "returns the registers" do
    expect(context.registers).to have_key(:site)
    expect(context.registers[:site]).to eql(site)
  end
end
