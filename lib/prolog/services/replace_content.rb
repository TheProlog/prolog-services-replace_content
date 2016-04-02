# frozen_string_literal: true

require 'pandoc-ruby'

require 'prolog/services/markdown_to_html'

require 'prolog/services/replace_content/content_replacer'
require 'prolog/services/replace_content/interpolator'
require 'prolog/services/replace_content/marker'
require 'prolog/services/replace_content/version'

module Prolog
  module Services
    # Replaces content within an HTML string based on endpoints and content.
    class ReplaceContent
      # Methods neither affecting nor affected by instance state.
      module Internals
        def self.to_html(content)
          Prolog::Services::MarkdownToHtml.call content: content
        end

        def self.to_markdown(content)
          PandocRuby.new(content, from: :html, to: :markdown_github).to_s
        end
      end
      private_constant :Internals

      attr_reader :content, :endpoints, :replacement

      def initialize(content: '', endpoints: (-1..-1), replacement: '')
        @content = content
        @endpoints = endpoints
        @replacement = replacement
        @content_after_conversion = nil
        self
      end

      def convert
        @content_after_conversion = Internals.to_html(markdown_with_markers)
        true
      end

      def converted_content
        content_after_conversion || :oops
      end

      private

      attr_reader :content_after_conversion

      def interpolator(marker)
        Interpolator.new content: content, endpoints: endpoints, marker: marker
      end

      def markdown_source(marker)
        ret = Internals.to_markdown(interpolator(marker).to_a.join)
        ret
      end

      def markdown_with_markers
        marker = Marker.new
        source = markdown_source marker
        replace_content source, marker
      end

      def replace_content(source, marker)
        ContentReplacer.new(source: source, marker: marker).with replacement
      end
    end # class Prolog::Services::ReplaceContent
  end
end
