# frozen_string_literal: true

RSpec.describe JekyllRelativeLinks::Context do
  subject { described_class.new(site) }

  let(:site) { fixture_site("site") }

  it "stores the site" do
    expect(subject.site).to eql(site)
  end

  it "returns the registers" do
    expect(subject.registers).to have_key(:site)
    expect(subject.registers[:site]).to eql(site)
  end
end