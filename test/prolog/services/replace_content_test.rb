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

      %i[content endpoints replacement].each do |attrib|
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

      # FUTURE: describe 'using source content as Markdown'
    end # describe 'with a complete set of valid attributes'
  end # describe 'when setting all attributes in the initialiser'

  describe 'when using attribute setters' do
    let(:obj) do
      described_class.set_content(
        described_class.set_endpoints(
          described_class.set_replacement(described_class.new, replacement),
          endpoints
        ),
        content
      )
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

      # FUTURE: describe 'using source content as Markdown'
    end # describe 'with a complete set of valid attributes'
  end # describe 'when using attribute setters'

  describe 'supports setting marker tag pairs in converted content' do
    let(:endpoints) { (endpoint_begin...endpoint_end) }
    let(:replacement) { 'replacement content' }
    let(:content) { '<p>This is a <em>simple</em> test.</p>' }
    let(:endpoint_begin) { content.index '<em>simple' }
    let(:endpoint_end) { content.index ' test.' }
    let(:expected) do
      marker_ary = Array(markers).flatten
      tag = marker_ary.first
      ident = marker_ary[1] || 'selection'
      fmt_str = '<p>This is a <%s id="%s-begin"></%s>replacement content' \
        '<%s id="%s-end"></%s> test.</p>'
      format fmt_str, tag, ident, tag, tag, ident, tag
    end
    let(:obj) { described_class.new params }
    let(:params) do
      { content: content, endpoints: endpoints, replacement: replacement }
    end

    before do
      obj.markers = markers
      obj.convert
    end

    describe 'using tag identifiers (symbols) only' do
      let(:markers) { :span }

      it 'produces the expected converted content' do
        expect(obj.converted_content).must_equal expected
      end
    end # describe 'using tag identifiers (symbols) only'

    describe 'using both tag identifiers and ID name prefix strings' do
      let(:markers) { [:span, 'whatever'] }

      it 'produces the expected converted content' do
        expect(obj.converted_content).must_equal expected
      end
    end # describe 'using both tag identifiers and ID name prefix strings'
  end # describe 'supports setting marker tag pairs in converted content'

  describe 'detects errors correctly, including' do
    describe 'invalid initial content' do
      let(:content) { '<p>This is a <em>simple</strong> test.</p>' }
      let(:endpoints) { (17...23) }
      let(:replacement) { 'basic' }

      it 'has #convert returning false' do
        expect(obj.convert).must_equal false
      end

      it 'is invalid' do
        obj.convert
        expect(obj).wont_be :valid?
      end

      it 'indicates an error when calling #converted_content' do
        obj.convert
        expect(obj.converted_content).must_equal :oops
      end

      it 'returns the correct error data from #errors' do
        obj.convert
        expected = { content: ['invalid'] }
        expect(obj.errors).must_equal expected
      end
    end # describe 'invalid enpoints (yielding invalid markup)'

    describe 'endpoints which' do
      describe 'invalidate the content as HTML' do
        let(:content) { '<p>This is a <em>simple</em> test.</p>' }
        let(:endpoints) { (15...23) }
        let(:replacement) { 'basic' }

        it 'is invalid' do
          obj.convert
          expect(obj).wont_be :valid?
        end

        it 'indicates an error when calling #converted_content' do
          obj.convert
          expect(obj.converted_content).must_equal :oops
        end

        it 'returns the correct error data from #errors' do
          obj.convert
          expected = { endpoints: ['invalid'] }
          expect(obj.errors).must_equal expected
        end
      end # describe 'invalidate the content as HTML'

      describe 'are out of valid range with respect to the content' do
        let(:content) { '<p>Testing.</p>' }
        let(:endpoints) { (0..-1) }
        let(:replacement) { 'anything' }

        after do
          obj.convert
          expected = { endpoints: ['invalid'] }
          expect(obj.errors).must_equal expected
        end

        it 'begin index' do
          params[:endpoints] = (800..-1)
        end

        # it 'end index' do
        #   params[:endpoints] = (0..800)
        # end
      end # describe 'are out of valid range with respect to the content'
    end # describe 'endpoints which'

    describe 'replacing content as specified produces invalid HTML' do
      let(:content) { '<ul><li>First item</li><li>Second item</li></ul>' }
      let(:endpoints) { (ep_begin...ep_end) }
      let(:ep_begin) { content.index 'Second' }
      let(:ep_end) { content.index '</ul>' }
      let(:replacement) { 'basic' }

      it 'has #convert returning false' do
        expect(obj.convert).must_equal false
      end

      it 'is invalid' do
        obj.convert
        expect(obj).wont_be :valid?
      end

      it 'indicates an error when calling #converted_content' do
        obj.convert
        expect(obj.converted_content).must_equal :oops
      end

      it 'returns the correct error data from #errors' do
        obj.convert
        expected = { replacement: ['invalid'] }
        expect(obj.errors).must_equal expected
      end
    end # describe 'replacing content as specified produces invalid HTML'

    describe 'failing to call #convert prior to calling #converted_content' do
      let(:endpoints) { (endpoint_begin...endpoint_end) }
      let(:replacement) { 'replacement content' }
      let(:content) do
        '<p>This is <em>source</em> material for the test.</p>'
      end
      let(:endpoint_begin) { content.index '<em>source' }
      let(:endpoint_end) { content.index ' for the test.' }

      before { @content = obj.converted_content }

      it 'is invalid' do
        expect(obj).wont_be :valid?
      end

      it 'indicates an error when calling #converted_content' do
        expect(@content).must_equal :oops
      end

      it 'returns the correct error data from #errors' do
        expected = { conversion: ['not called'] }
        expect(obj.errors).must_equal expected
      end
    end # describe 'failing to call #convert prior to ... #converted_content'
  end # describe 'detects errors correctly, including'
end
