# frozen_string_literal: true

require 'pandoc-ruby'
# require 'semantic_logger'

require 'prolog/services/markdown_to_html'

require 'prolog/services/replace_content/version'

module Prolog
  module Services
    # Replaces content within an HTML string based on endpoints and content.
    class ReplaceContent
      # Methods neither affecting nor affected by instance state.
      module Internals
        def self.cleanup_lists_after_pandoc(html)
          ret = html.gsub(/l>\s/, 'l>')
          ret.gsub!(/li>\s/, 'li>')
          # Oddly, Linux Pandoc inserts a break at end of first list item.
          ret.gsub!(%r{<br \/><\/li>}, '</li>')
          ret
        end

        def self.to_html(content)
          Prolog::Services::MarkdownToHtml.call content: content
        end

        def self.to_markdown(content)
          PandocRuby.new(content, from: :html, to: :markdown_github).to_s
        end
      end
      private_constant :Internals

      # include SemanticLogger::Loggable

      attr_reader :content, :endpoints, :replacement

      def initialize(content: '', endpoints: (-1..-1), replacement: '')
        @content = content
        @endpoints = endpoints
        @replacement = replacement
        @content_after_conversion = nil
        self
      end

      # This is a transitional implementation; we know RuboCop and Reek won't be
      # happy with it for a while, and we're fine with that, because it isn't
      # anywhere close to final yet.
      # :reek:TooManyStatements
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def convert
        parts = [content[0...endpoints.begin], content[endpoints.end..-1]]
        middle = content[endpoints]
        marker = 'zqxzqxzqx'
        inner = [marker, marker].join middle
        markdown = PandocRuby.convert parts.join(inner), from: :html,
                                                         to: :markdown_github
        html = PandocRuby.convert(markdown, from: :markdown_github,
                                            to: :html).chomp
        # Pandoc leaves newlines on list items and `<ul>` opening and closing
        # tags when it converts; we can safely strip those
        html = Internals.cleanup_lists_after_pandoc(html)
        @content_after_conversion = html.sub(inner, replacement)
        true
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def converted_content
        content_after_conversion || :oops
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

      attr_reader :content_after_conversion
    end # class Prolog::Services::ReplaceContent
  end
end
