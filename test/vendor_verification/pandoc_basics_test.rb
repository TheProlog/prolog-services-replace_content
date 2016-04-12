# frozen_string_literal: true

require 'test_helper'
require 'rbconfig'

require 'pandoc-ruby'

is_linux = RbConfig::CONFIG['host_os'] == 'linux-gnu'
is_osx = RbConfig::CONFIG['host_os'].match(/^darwin/)

describe 'Pandoc basics' do
  describe 'has OS-dependent parsing of identified anchor pairs' do
    let(:html_content) do
      content = <<~ENDIT
      <p>This is <a id="contrib-99"></a>
      obviously <em>sample and disposable</em> content.
      </p>
      ENDIT
      content.lines.map(&:chomp).join
    end
    let(:markdown) do
      PandocRuby.convert(html_content, from: :html, to: :markdown_github)
    end
    let(:converted_html) do
      # Pandoc adds a aterminating "\n"; kill it.
      PandocRuby.convert(markdown, from: :markdown_github, to: :html).chomp
    end
    # let(:fiddled_content) do
    #   html_content.sub('<a id="contrib-99"></a>', 'QQ99QQ')
    # end
    let(:fiddled_markdown) do
      md = PandocRuby.convert(html_content, from: :html, to: :markdown_github)
      md.sub('QQ99QQ', '<a id="contrib-99"></a>')
    end
    let(:fiddled_html) do
      PandocRuby.convert(fiddled_markdown, from: :markdown_github,
                                           to: :html).chomp
    end

    describe 'on OS X but not on Linux' do
      # Changed sometime between Pandoc 1.15.1 and 1.17.0.3.
      it 'adds empty :href attributes to empty :a tags' do
        fiddled = html_content.gsub('<a id', '<a href="" id')
        expect(converted_html).must_equal fiddled if is_osx
      end
    end # describe 'on OS X but not on Linux'

    # This is true for `pandoc-ruby` 2.0.0 on Linux. That Gem talking to Pandoc
    # under Mac OS X does not *require* "fiddling" except to add the `a href=""`
    # attributes to the anchor tag.
    describe 'only on Linux' do
      it 'removes the identified anchor pair from the converted Markdown' do
        strips_anchors = markdown.match(/contrib/)
        expect(strips_anchors).must_be(:nil?) if is_linux
        expect(strips_anchors).wont_be(:nil?) if is_osx
      end

      it 'omits the identified anchor pair from the converted Markdown' do
        stripped = html_content.sub('<a id="contrib-99"></a>', '')
        expect(converted_html).must_equal stripped if is_linux
        expect(converted_html).wont_equal stripped if is_osx
      end
    end # describe 'only on Linux'

    describe 'on either Linux or OS X' do
      it 'does not produce lexically identical content' do
        expect(converted_html).wont_equal html_content
      end

      it 'correctly converts the "fiddled" content => Markdown => HTML' do
        fiddled = fiddled_html.gsub('<a id', '<a href="" id')
        expect(fiddled_html).must_equal fiddled
      end
    end # describe 'on either Linux or OS X'
  end # describe 'has OS-dependent parsing of identified anchor pairs'
end
