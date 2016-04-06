# frozen_string_literal: true

require 'test_helper'

require 'pandoc-ruby'

describe 'Pandoc basics' do
  describe 'converts empty anchor tag pairs with IDs to span tag pairs' do
    let(:html_content) do
      content = %(<p>This is
        <a id="contribution-27-begin"></a>
        <a id="contribution-9-begin"></a>
        obviously
        <em>sample
          <a id="contribution-27-end"></a>
          and disposable
        </em>
        content.
        <a id="contribution-9-end"></a>
      </p>)
      content.lines.map(&:strip).join
    end
    let(:markdown) do
      PandocRuby.convert(html_content, from: :html, to: :markdown_github)
    end
    let(:converted_html) do
      # Pandoc adds a aterminating "\n"; kill it."
      PandocRuby.convert(markdown, from: :markdown_github, to: :html).chomp
    end

    it 'does not produce lexically identical content' do
      expect(converted_html).wont_equal html_content
    end

    it 'replaces empty :a tags with :span tags' do
      fiddled = html_content.gsub('<a id', '<span id').gsub('</a>', '</span>')
      expect(fiddled).must_equal converted_html
    end
  end # describe 'converts empty anchor tag pairs with IDs to span tag pairs'

  describe 'correctly handles Markdown with embedded HTML tag pairs' do
    describe 'when converting the lot to HTML' do
      let(:mixed_source) do
        'This is <a id="foo-begin"></a>*emphasised content*<a id="foo-end">' \
          '</a> and regular content.'
      end
      let(:equivalent_html) do
        '<p>This is <a id="foo-begin"></a><em>emphasised content</em>' \
          '<a id="foo-end"></a> and regular content.</p>'
      end
      let(:converted_html) do
        PandocRuby.convert(mixed_source, from: :markdown_github, to: :html)
      end

      it 'preserving the embedded HTML' do
        expect(converted_html.chomp).must_equal equivalent_html
      end
    end
  end # describe 'correctly handles Markdown with embedded HTML tag pairs'
end
