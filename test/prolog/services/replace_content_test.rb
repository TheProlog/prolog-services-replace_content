
require 'test_helper'

describe 'Prolog::Services::ReplaceContent' do
  it 'has a version number in SemVer format' do
    actual = Prolog::Services::ReplaceContent::VERSION
    expect(actual).must_match(/\d+\.\d+\.\d+/)
  end
end
