# frozen_string_literal: true

require 'test_helper'
require 'semantic_logger'

require 'pandoc-ruby'

tag :focus
describe 'Pandoc basics' do
  before do
    SemanticLogger.default_level = :trace
    @logger = SemanticLogger['PandocBasics']
  end

  describe 'converts empty anchor tag pairs with IDs to span tag pairs' do
    let(:html_content) do
      content = <<~ENDIT
      <p>This is
       <a id="contribution-27-begin"></a>
      <a id="contribution-9-begin"></a>
      obviously
       <em>sample
       <a id="contribution-27-end"></a>
       and disposable
      </em>
       content.
      <a id="contribution-9-end"></a>
      </p>
      ENDIT
      content.lines.map(&:chomp).join
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

    # Changed sometime between Pandoc 1.15.1 and 1.17.0.3.
    it 'adds empty :href attributes to empty :a tags' do
      fiddled = html_content.gsub('<a id', '<a href="" id')
      @logger.trace 'adds empty :href attribute', fiddled: fiddled,
                                                  markdown: markdown,
                                                  html_content: html_content,
                                                  converted_html: converted_html
      expect(converted_html).must_equal fiddled
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
