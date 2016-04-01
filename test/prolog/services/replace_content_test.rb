
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
end
