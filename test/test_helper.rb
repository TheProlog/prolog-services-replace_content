# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'pry-byebug'
require 'simplecov'
require 'minitest/spec'
require 'minitest/autorun'
require 'awesome_print'
require 'semantic_logger'

uses_cova = ENV['COVERALLS_REPO_TOKEN']
uses_cc = ENV['CODECLIMATE_REPO_TOKEN']

SimpleCov.start do
  coverage_dir './tmp/coverage'
  add_filter '/lib/tasks/'
  add_filter '/tmp/gemset/'
end

reporter_class = SimpleCov

sc_formatters = [
  SimpleCov::Formatter::HTMLFormatter
]
# formatter SimpleCov::Formatter::MultiFormatter[*sc_formatters]

if uses_cc
  require 'codeclimate-test-reporter'
  reporter_class = CodeClimate::TestReporter
  sc_formatters.unshift CodeClimate::TestReporter::Formatter
end

reporter_class.start do
  if uses_cova
    require 'coveralls'
    sc_formatters.unshift(Coveralls::SimpleCov::Formatter)
  end

  self.formatters = sc_formatters
  Coveralls.wear! if uses_cova
end

# if uses_cc
#   CodeClimate.TestReporter.start
# end

require 'semantic_logger'
SemanticLogger.default_level = :trace
SemanticLogger.add_appender file_name: 'log/testing.log', formatter: :color

require 'minitest/autorun' # harmless if already required
require 'minitest/reporters'
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(
  color: true, detailed_skip: true, fast_fail: true
)]

# Set up MiniTest::Tagz, with stick-it-anywhere `:focus` support.
require 'minitest/tagz'
tags = ENV['TAGS'].split(',') if ENV['TAGS']
tags ||= []
tags << 'focus'
Minitest::Tagz.choose_tags(*tags, run_all_if_no_match: true)
