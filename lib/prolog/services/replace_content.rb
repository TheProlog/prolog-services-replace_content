# frozen_string_literal: true

require 'prolog/services/replace_content/content_splitter'
require 'prolog/services/replace_content/converter'
require 'prolog/services/replace_content/version'

module Prolog
  module Services
    # Replaces content within an HTML string based on endpoints and content.
    # FIXME: Reek thinks this has :reek:TooManyInstanceVariables; cleanup soonn.
    class ReplaceContent
      attr_reader :content, :endpoints, :errors, :replacement

      def initialize(content: '', endpoints: (-1..-1), replacement: '')
        @content = content
        @endpoints = endpoints
        @replacement = replacement
        @content_after_conversion = nil
        @errors = {}
        self
      end

      def convert
        validate
        return false unless valid?
        @content_after_conversion = Converter.convert(splitter, replacement)
        true
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def converted_content
        @content_after_conversion || :oops
      end

      def valid?
        errors.empty?
      end

      def self.set_content(obj, content)
        new endpoints: obj.endpoints, replacement: obj.replacement,
            content: content
      end

      def self.set_endpoints(obj, endpoints)
        new content: obj.content, replacement: obj.replacement,
            endpoints: endpoints
      end

      def self.set_replacement(obj, replacement)
        new content: obj.content, endpoints: obj.endpoints,
            replacement: replacement
      end

      private

      def parse_with_comments
        comment = '<!-- -->'
        twiddled = splitter(comment).source
        Ox.parse twiddled # raises on most errors
      end

      def splitter(marker = ContentSplitter::DEFAULT_MARKER)
        ContentSplitter.new content: content, endpoints: endpoints,
                            marker: marker
      end

      def validate
        validate_content && validate_endpoints
      end

      # FIXME: Reek says :reek:TooManyStatements. It's right.
      def validate_content
        Ox.parse @content
      rescue Ox::ParseError
        errors[:content] = ['invalid']
        false
      end

      def validate_endpoints
        parse_with_comments
        true
      rescue Ox::ParseError
        errors[:endpoints] = ['invalid']
        false
      end
    end # class Prolog::Services::ReplaceContent
  end
end
