# frozen_string_literal: true

require 'test_helper'

require 'prolog/services/replace_content'

describe 'Prolog::Services::ReplaceContent' do
  let(:described_class) { Prolog::Services::ReplaceContent }
  let(:obj) { described_class.new params }
  let(:params) do
    { content: content, endpoints: endpoints, replacement: replacement }
  end

  it 'has a version number in SemVer format' do
    actual = Prolog::Services::ReplaceContent::VERSION
    expect(actual).must_match(/\d+\.\d+\.\d+/)
  end

  describe 'initialisation' do
    it 'succeeds without specified parameters' do
      expect(described_class.new).must_be_instance_of described_class
    end

    describe 'accepts parameters for' do
      let(:the_method) { described_class.new.method :initialize }

      [:content, :endpoints, :replacement].each do |attrib|
        it ":#{attrib}" do
          params = [:key, attrib]
          expect(the_method.parameters).must_include params
        end
      end
    end # describe 'accepts parameters for'
  end # describe 'initialisation'

  describe 'when setting all attributes in the initialiser' do
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
    let(:obj) do
      described_class.set_content(
        described_class.set_endpoints(
          described_class.set_replacement(described_class.new, replacement),
          endpoints),
        content)
    end
    let(:converted_content) { '<ul><li>First</li><li>Last</li></ul>' }
    let(:replacement) { 'Last' }

    before { obj.convert }

    describe 'with a complete set of valid attributes' do
      let(:endpoints) { (endpoint_begin...endpoint_end) }

      describe 'using source content as HTML' do
        let(:content) { '<ul><li>First</li><li>Second</li></ul>' }
        let(:endpoint_begin) { content.index 'Second' }
        let(:endpoint_end) { content.index '</li></ul>' }

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
        let(:content) do
          <<~ENDIT
          - First
          - Second
          ENDIT
        end
        let(:endpoints) { (endpoint_begin...endpoint_end) }
        let(:endpoint_begin) { content.index 'Second' }
        let(:endpoint_end) { -1 }

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
  end # describe 'when using attribute setters'

  describe 'detects errors correctly, including' do
    describe 'invalid initial content' do
      let(:content) { '<p>This is a <em>simple</strong> test.</p>' }
      let(:endpoints) { (17...23) }
      let(:replacement) { 'basic' }

      it 'has #convert returning false' do
        expect(obj.convert).must_equal false
      end
    end # describe 'invalid enpoints (yielding invalid markup)'
  end # describe 'detects errors correctly, including'
end
