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

      include SemanticLogger::Loggable

      attr_reader :content, :endpoints, :replacement

      def initialize(content: '', endpoints: (-1..-1), replacement: '')
        logger.trace 'Entering #initialize', content: content,
                                             endpoints: endpoints,
                                             replacement: replacement
        @content = content
        @endpoints = endpoints
        @replacement = replacement
        @content_after_conversion = nil
        self
      end

      def convert
        @content_after_conversion = Internals.to_html(markdown_with_markers)
        logger.trace 'Setting @content_after_conversion',
                     '@coc': @content_after_conversion
        true
      end

      def converted_content
        logger.trace 'In #converted_content', cac: content_after_conversion
        content_after_conversion || :oops
      end

      private

      attr_reader :content_after_conversion

      def interpolator(marker)
        logger.trace 'Building an Interpolator', content: content,
                                                 endpoints: endpoints,
                                                 marker: marker
        ret = Interpolator.new content: content, endpoints: endpoints,
                               marker: marker
        logger.trace '#interpolator is returning', ret: ret
        ret
      end

      def markdown_source(marker)
        ret = Internals.to_markdown(interpolator(marker).to_a.join)
        logger.trace '#markdown_source is returning', ret: ret, marker: marker
        ret
      end

      # Reek points out that this has :reek:TooManyStatements with the logging.
      def markdown_with_markers
        marker = Marker.new
        source = markdown_source marker
        logger.trace 'In markdown_with_markers', source: source
        ret = replace_content source, marker
        logger.trace '#markdown_with_markers is returning', ret: ret
        ret
      end

      def replace_content(source, marker)
        params = { source: source, marker: marker }
        ret = ContentReplacer.new(params).with replacement
        logger.trace '#replace_content is returning', ret: ret, params: params
        ret
      end
    end # class Prolog::Services::ReplaceContent
  end
end
