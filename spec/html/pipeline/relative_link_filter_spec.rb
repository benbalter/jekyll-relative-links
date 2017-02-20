RSpec.describe HTML::Pipeline::RelativeLinkFilter do
  def filter_link(url)
    content = %(<a href="#{url}">thing</a>)
    result = HTML::Pipeline::RelativeLinkFilter.new(content, context, nil).call
    result.search("a").first.attribute("href").value
  end

  describe "anchors" do
    context "with a root of /root" do
      let(:context) do
        { :current_url => "", :base_url => "/root" }
      end

      it "prefixes relative urls with root" do
        expect(filter_link("relative")).to eql("/root/relative")
      end

      it "prefixes relative urls with root and current path" do
        context[:current_url] = "current/page"
        expect(filter_link("relative")).to eql("/root/current/relative")
      end

      it "prefixes relative urls with root and current path as a directory" do
        context[:current_url] = "current/page/"
        expect(filter_link("relative")).to eql("/root/current/page/relative")
      end

      it "makes absolute urls relative to root" do
        context[:current_url] = "current/page"
        expect(filter_link("/absolute")).to eql("/root/absolute")
      end

      it "does not duplicate root if it already exists" do
        expect(filter_link("/root/foo")).to eql("/root/foo")
      end

      it "ignores external URLs" do
        expect(filter_link("https://example.com")).to eql("https://example.com")
      end

      it "ignores hashes" do
        expect(filter_link("#foobar")).to eql("#foobar")
      end

      it "ignores protocol relative urls" do
        expect(filter_link("//example.com")).to eql("//example.com")
      end

      it "ignores anchors without an href" do
        content = %(<a name="foo">thing</a>)
        result = HTML::Pipeline::RelativeLinkFilter.new(content, context, nil).call
        href = result.search("a").first.attribute("href")
        expect(href).to be(nil)
      end
    end

    context "with an empty root" do
      let(:context) do
        { :current_url => "", :base_url => "" }
      end

      it "prefixes relative urls with root" do
        expect(filter_link("relative")).to eql("/relative")
      end

      it "prefixes relative urls with root and current path" do
        context[:current_url] = "current/page"
        expect(filter_link("relative")).to eql("/current/relative")
      end

      it "prefixes relative urls with root and current path as a directory" do
        context[:current_url] = "current/page/"
        expect(filter_link("relative")).to eql("/current/page/relative")
      end

      it "makes absolute urls relative to root" do
        context[:current_url] = "current/page"
        expect(filter_link("/absolute")).to eql("/absolute")
      end
    end

    context "with a fully-qualified base" do
      let(:context) do
        { :current_url => "", :base_url => "http://example.com/foo" }
      end

      it "prefixes relative urls with root" do
        expect(filter_link("relative")).to eql("http://example.com/foo/relative")
      end

      it "prefixes relative urls with root and current path" do
        context[:current_url] = "current/page"
        expect(filter_link("relative")).to eql("http://example.com/foo/current/relative")
      end

      it "prefixes relative urls with root and current path as a directory" do
        context[:current_url] = "current/page/"
        expect(filter_link("relative")).to eql(
          "http://example.com/foo/current/page/relative"
        )
      end

      it "makes absolute urls relative to root" do
        context[:current_url] = "current/page"
        expect(filter_link("/absolute")).to eql("http://example.com/foo/absolute")
      end

      it "does not duplicate root if it already exists" do
        expect(filter_link("/foo/bar")).to eql("http://example.com/foo/bar")
      end
    end
  end

  describe "images" do
    def filter_img(url)
      content = %(<img src="#{url}">)
      result = HTML::Pipeline::RelativeLinkFilter.new(content, context, nil).call
      result.search("img").first.attribute("src").value
    end

    context "with a root of /root" do
      let(:context) do
        { :current_url => "", :base_url => "/root" }
      end

      it "prefixes relative urls with root" do
        expect(filter_img("relative.png")).to eql("/root/relative.png")
      end

      it "prefixes relative urls with root and current path" do
        context[:current_url] = "current/page"
        expect(filter_img("relative.png")).to eql("/root/current/relative.png")
      end

      it "prefixes relative urls with root and current path as a directory" do
        context[:current_url] = "current/page/"
        expect(filter_img("relative.png")).to eql("/root/current/page/relative.png")
      end

      it "makes absolute urls relative to root" do
        context[:current_url] = "current/page"
        expect(filter_img("/absolute.png")).to eql("/root/absolute.png")
      end

      it "ignores external URLs" do
        expect(filter_img("https://example.com/foo.png")).to eql(
          "https://example.com/foo.png"
        )
      end

      it "ignores protocol relative urls" do
        expect(filter_img("//example.com/foo.png")).to eql("//example.com/foo.png")
      end

      it "ignores images without a src" do
        content = %(<img alt="yep">)
        result = HTML::Pipeline::RelativeLinkFilter.new(content, context, nil).call
        src = result.search("img").first.attribute("src")
        expect(src).to be(nil)
      end
    end

    context 'with a root of ""' do
      let(:context) do
        { :current_url => "", :base_url => "" }
      end

      it "prefixes relative urls with root" do
        expect(filter_img("relative")).to eql("/relative")
      end

      it "prefixes relative urls with root and current path" do
        context[:current_url] = "current/page"
        expect(filter_img("relative")).to eql("/current/relative")
      end

      it "prefixes relative urls with root and current path as a directory" do
        context[:current_url] = "current/page/"
        expect(filter_img("relative")).to eql("/current/page/relative")
      end

      it "makes absolute urls relative to root" do
        context[:current_url] = "current/page"
        expect(filter_img("/absolute")).to eql("/absolute")
      end
    end
  end
end
