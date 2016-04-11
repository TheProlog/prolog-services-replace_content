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
    let(:endpoints) { (endpoint_begin...endpoint_end) }
    let(:replacement) { 'replacement content' }
    let(:content) { 'REDEFINE THIS CONTENT' }
    let(:converted_content) do
      '<p>This is replacement content for the test.</p>'
    end
    let(:endpoint_begin) { 0 }
    let(:endpoint_end) { -1 }

    describe 'with a complete set of valid attributes' do
      before { obj.convert }

      describe 'using source content as HTML' do
        let(:content) do
          '<p>This is <em>source</em> material for the test.</p>'
        end
        let(:endpoint_begin) { content.index '<em>source' }
        let(:endpoint_end) { content.index ' for the test.' }

        it 'is valid' do
          expect(obj).must_be :valid?
        end

        it 'has no errors' do
          expect(obj.errors).must_be :empty?
        end

        it 'produces correct converted content' do
          expect(obj.converted_content).must_equal converted_content
        end

        it 'does not modify the original content' do
          expect(obj.content).must_equal content
        end
      end # describe 'using source content as HTML'

      describe 'using source content as Markdown' do
        let(:content) { 'This is *source* material for the test.' }
        let(:endpoint_begin) { content.index '*source' }
        let(:endpoint_end) { content.index ' for the test.' }

        it 'is valid' do
          expect(obj).must_be :valid?
        end

        it 'has no errors' do
          expect(obj.errors).must_be :empty?
        end

        it 'produces correct converted content' do
          expect(obj.converted_content).must_equal converted_content
        end

        it 'does not modify the original content' do
          expect(obj.content).must_equal content
        end
      end # describe 'using source content as Markdown'
    end # describe 'with a complete set of valid attributes'
  end # describe 'when setting all attributes in the initialiser'

  describe 'when using attribute setters' do
    let(:obj) { described_class.new }

    describe 'with a complete set of valid attributes' do
      describe 'using source content as HTML' do
        let(:content) { '<ul><li>First</li><li>Second</li></ul>' }
        let(:converted_content) { '<ul><li>First</li><li>Last</li></ul>' }
        let(:replacement) { 'Last' }
        let(:endpoints) { (endpoint_begin...endpoint_end) }
        let(:endpoint_begin) { content.index 'Second' }
        let(:endpoint_end) { content.index '</li></ul>' }

        it 'is valid'

        it 'has no errors'

        it 'produces correct converted content' do
          obj = described_class.new
          obj = described_class.set_content obj, content
          obj = described_class.set_endpoints obj, endpoints
          obj = described_class.set_replacement obj, replacement
          obj.convert
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
  end # describe 'when using attribute setters'
end
