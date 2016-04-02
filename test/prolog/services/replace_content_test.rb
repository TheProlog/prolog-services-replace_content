
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
  end # describe 'when setting all attributes in the initialiser'

  describe 'when using attribute setters' do
  end # describe 'when using attribute setters'
end
