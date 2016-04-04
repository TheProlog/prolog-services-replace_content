# frozen_string_literal: true

require 'test_helper'

require 'prolog/services/replace_content'

describe 'Prolog::Services::ReplaceContent' do
  let(:described_class) { Prolog::Services::ReplaceContent }

  it 'has a version number in SemVer format' do
    actual = Prolog::Services::ReplaceContent::VERSION
    expect(actual).must_match(/\d+\.\d+\.\d+/)
  end

  describe 'initialisation' do
    it 'succeeds without specified parameters' do
      expect { described_class.new }.must_be_silent
    end

    describe 'accepts parameters for' do
      let(:dummy) { Object.new }

      [:content, :endpoints, :replacement].each do |attrib|
        it ":#{attrib}" do
          params = {}
          params[attrib] = dummy
          expect { described_class.new params }.must_be_silent
        end
      end
    end # describe 'accepts parameters for'
  end # describe 'initialisation'

  describe 'when setting all attributes in the initialiser' do
    let(:obj) { described_class.new params }
    let(:params) do
      { content: content, endpoints: endpoints, replacement: replacement }
    end
    let(:endpoints) { (endpoint_begin..endpoint_end) }
    let(:replacement) { 'replacement content' }
    let(:content) { 'REDEFINE THIS CONTENT' }
    let(:endpoint_begin) { 0 }
    let(:endpoint_end) { -1 }

    describe 'with a complete set of valid attributes' do
      describe 'using source content as HTML' do
        before { obj.convert }

        let(:content) do
          '<p>This is <em>source</em> material for the test.</p>'
        end
        let(:converted_content) do
          '<p>This is replacement content for the test.</p>'
        end
        let(:endpoint_begin) { content.index '<em>source' }
        let(:endpoint_end) { content.index ' for the test.' }

        it 'is valid'

        it 'has no errors'

        tag :focus
        it 'produces correct converted content' do
          expect(obj.converted_content).must_equal converted_content
        end

        it 'does not modify the original content'
      end # describe 'using source content as HTML'

      describe 'using source content as Markdown' do
        it 'is valid'

        it 'has no errors'

        it 'produces correct converted content'

        it 'does not modify the original content'
      end # describe 'using source content as Markdown'
    end # describe 'with a complete set of valid attributes'
  end # describe 'when setting all attributes in the initialiser'

  describe 'when using attribute setters' do
    describe 'with a complete set of valid attributes' do
      describe 'using source content as HTML' do
        it 'is valid'

        it 'has no errors'

        it 'produces correct converted content'

        it 'does not modify the original content'
      end # describe 'using source content as HTML'

      describe 'using source content as Markdown' do
        it 'is valid'

        it 'has no errors'

        it 'produces correct converted content'

        it 'does not modify the original content'
      end # describe 'using source content as Markdown'
    end # describe 'with a complete set of valid attributes'
  end # describe 'when using attribute setters'
end
