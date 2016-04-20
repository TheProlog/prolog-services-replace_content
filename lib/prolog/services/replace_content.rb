# frozen_string_literal: true

require 'ox'

require 'prolog/services/replace_content/splitter/symmetric'
require 'prolog/services/replace_content/version'

module Prolog
  module Services
    # Replaces content within an HTML string based on endpoints and content.
    # FIXME: Reek thinks this has :reek:TooManyInstanceVariables; cleanup soonn.
    class ReplaceContent
      attr_reader :content, :endpoints, :errors, :markers, :replacement

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
        set_converted_content
        valid?
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def converted_content
        errors[:conversion] = ['not called'] unless @content_after_conversion
        @content_after_conversion || :oops
      end

      # def markers=(*params)
      #   @markers = params
      # end

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

      def build_converted_content
        replace_inner_content_in splitter.source
      end

      def replace_inner_content_in(markup)
        markup.sub(splitter.inner, replacement)
      end

      def set_converted_content
        html = build_converted_content
        @content_after_conversion = html if validate_markup(html, :replacement)
        @content_after_conversion
      end

      def parse_with_comments
        comment = '<!-- -->'
        twiddled = splitter(comment).source
        Ox.parse twiddled # raises on most errors
      end

      def splitter(marker = Splitter::Symmetric::DEFAULT_MARKER)
        # ap [:line_83, @markers, marker]
        Splitter::Symmetric.new content: content, endpoints: endpoints,
                                marker: marker
      end

      def validate
        validate_content && validate_endpoints
      end

      def validate_content
        validate_markup @content, :content
      end

      def validate_markup(markup, error_key)
        Ox.parse markup
        true
      rescue Ox::ParseError
        errors[error_key] = ['invalid']
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
