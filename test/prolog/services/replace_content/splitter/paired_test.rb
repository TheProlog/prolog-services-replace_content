# frozen_string_literal: true

require 'test_helper'

require 'prolog/services/replace_content/splitter/paired'

describe 'Prolog::Services::ReplaceContent::Splitter::Paired' do
  let(:described_class) { Prolog::Services::ReplaceContent::Splitter::Paired }
  let(:content) { '<p>This is example content.</p>' }
  let(:endpoints) { (ep_begin...ep_end) }
  let(:ep_begin) { content.index 'example' }
  let(:ep_end) { content.index ' content.' }
  let(:identifier) { 'selection' }
  let(:inner) { content[endpoints] }
  let(:params) { { content: content, endpoints: endpoints } }
  let(:tag) { :a }
  let(:obj) { described_class.new params }

  describe 'within the simplest golden path' do
    describe 'can be initialised with' do
      it ':content and :endpoints parameters' do
        expect { obj }.must_be_silent
      end
    end # describe 'can be initialised with'

    describe 'has an #inner method that' do
      # Remenber that "within the endpoints" should be read as "from the index
      # specified by the begin endpoint up to BUT NOT INCLUDING the index
      # specified by the end endpoint". That's reflected in how the `endpoints`
      # fixture is defined above: three dots rather than two (which would
      # instead make the range "up to and including the end endpoint").
      it 'returns the source content contained within the endpoints' do
        expect(obj.inner).must_equal content[endpoints]
      end
    end # describe 'has an #inner method that'

    describe 'has a #source method that' do
      it 'returns the expected content, including content wrapped by markers' do
        marker_fmt = %(<%s id="%s-%s"></%s>)
        begin_marker = format marker_fmt, tag, identifier, :begin, tag
        end_marker = format marker_fmt, tag, identifier, :end, tag
        expected = [content[0...ep_begin], begin_marker, inner, end_marker,
                    content[ep_end..-1]].join
        expect(obj.source).must_equal expected
      end
    end # describe 'has a #source method that'
  end # describe 'within the simplest golden path'
end
