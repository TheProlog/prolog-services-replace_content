# frozen_string_literal: true

require 'test_helper'

require 'prolog/services/replace_content/splitter/symmetric'

describe 'Prolog::Services::ReplaceContent::Splitter::Symmetric' do
  let(:described_class) do
    Prolog::Services::ReplaceContent::Splitter::Symmetric
  end
  let(:content) { 'The five boxing wizards jump quickly.' }

  describe 'when initialised using the default (empty) marker' do
    let(:obj) { described_class.new content: content, endpoints: endpoints }

    describe 'and a non-repeating content string' do
      describe 'and endpoints are set that' do
        describe 'include the entire content' do
          let(:endpoints) { (0..-1) }

          it 'returns the entire original content as the "inner" content' do
            expect(obj.inner).must_equal content
          end

          it 'returns the entire original content as the "source" content' do
            expect(obj.source).must_equal content
          end
        end # describe 'include the entire content'

        describe 'include a sub-range of the content' do
          let(:endpoints) { (4..14) } # "five boxing"

          it 'returns correct original content section as "inner" content' do
            expect(obj.inner).must_equal content[endpoints]
          end

          it 'returns the entire original content as the "source" content' do
            expect(obj.source).must_equal content
          end
        end # describe 'include a sub-range of the content'
      end # describe 'and endpoints are set that'
    end # describe 'and a non-repeating content string'
  end # describe 'when initialised using the default (empty) marker'

  describe 'when initialised using an explicit marker' do
    let(:marker) { '<!-- -->' }
    let(:obj) do
      described_class.new content: content, endpoints: endpoints, marker: marker
    end

    describe 'and endpoints are set that' do
      describe 'include the entire content' do
        let(:endpoints) { (0..-1) }

        it 'wraps all original content in a pair of markers as "inner"' do
          expected = [marker, marker].join content[endpoints]
          expect(obj.inner).must_equal expected
        end

        it 'returns the same value for "source" as for "inner"' do
          expect(obj.source).must_equal obj.inner
        end
      end # describe 'include the entire content'

      describe 'include a sub-range of the content' do
        let(:endpoints) { (4..14) } # "five boxing"

        it 'returns the correct original content section as "inner" content' do
          expected = [marker, marker].join content[endpoints]
          expect(obj.inner).must_equal expected
        end

        it 'returns the entire original content as the "source" content' do
          parts = content.split content[endpoints]
          expected = parts.join obj.inner
          expect(obj.source).must_equal expected
        end
      end # describe 'include a sub-range of the content'
    end # describe 'and endpoints are set that'

    describe 'and a content string with repeating character sequences' do
      let(:content) do
        %w(How much wood could a wood chuck chuck if a wood chuck could chuck
           wood?).join ' '
      end
      let(:endpoints) { (44..47) } # third of four 'wood' occurrences

      it 'returns the correct original content section as "inner" content' do
        expected = [marker, marker].join content[endpoints]
        expect(obj.inner).must_equal expected
      end

      it 'returns the entire original content as the "source" content' do
        expected = content.dup
        expected[endpoints] = [marker, marker].join content[endpoints]
        expect(obj.source).must_equal expected
      end
    end # describe 'and a content string with repeating character sequences'
  end # describe 'when initialised using an explicit marker'
end
