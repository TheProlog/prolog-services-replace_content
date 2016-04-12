# frozen_string_literal: true

require 'prolog/services/replace_content/content_splitter'
require 'prolog/services/replace_content/converter'
require 'prolog/services/replace_content/version'

module Prolog
  module Services
    # Replaces content within an HTML string based on endpoints and content.
    class ReplaceContent
      attr_reader :content, :endpoints, :replacement

      def initialize(content: '', endpoints: (-1..-1), replacement: '')
        @content = content
        @endpoints = endpoints
        @replacement = replacement
        @content_after_conversion = nil
        self
      end

      def convert
        @content_after_conversion = Converter.convert(splitter, replacement)
        true
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def converted_content
        @content_after_conversion || :oops
      end

      def errors
        {}
      end

      def valid?
        true
      end

      def self.set_content(obj, content)
        endpoints = obj.endpoints
        replacement = obj.replacement
        new content: content, endpoints: endpoints, replacement: replacement
      end

      def self.set_endpoints(obj, endpoints)
        content = obj.content
        replacement = obj.replacement
        new content: content, endpoints: endpoints, replacement: replacement
      end

      def self.set_replacement(obj, replacement)
        content = obj.content
        endpoints = obj.endpoints
        new content: content, endpoints: endpoints, replacement: replacement
      end

      private

      def splitter
        ContentSplitter.new content: content, endpoints: endpoints
      end
    end # class Prolog::Services::ReplaceContent
  end
end
