# frozen_string_literal: true

require 'ox'
require 'pandoc-ruby'

module Prolog
  module Services
    # Replaces content within an HTML string based on endpoints and content.
    class ReplaceContent
      # Converts HTML or Markdown to HTML with "inner" content delimited.
      class Converter
        # Methods neither affecting nor affected by instance state.
        module Internals
          def self.cleanup_lists_after_pandoc(html)
            ret = html.gsub(/l>\s/, 'l>')
            ret.gsub!(/li>\s/, 'li>')
            # Oddly, Linux Pandoc inserts a break at end of first list item.
            ret.gsub!(%r{<br \/><\/li>}, '</li>')
            ret
          end

          def self.from_html_source(splitter, replacement)
            html = cleanup_lists_after_pandoc(splitter.source)
            html.sub!(splitter.inner, replacement)
            html
          end

          def self.from_markdown_source(splitter, replacement)
            markdown = rebuild_markdown(splitter, replacement)
            PandocRuby.convert(markdown, from: :markdown_github,
                                         to: :html).chomp
          end

          def self.html?(splitter)
            Ox.parse splitter.source
            return true
          rescue Ox::ParseError
            false
          end

          def self.rebuild_html(splitter, replacement)
            return from_html_source(splitter, replacement) if html?(splitter)
            from_markdown_source(splitter, replacement)
          end

          def self.rebuild_markdown(splitter, replacement)
            markdown = splitter.source + "\n"
            markdown.sub!(splitter.inner, replacement)
          end
        end
        private_constant :Internals

        def self.convert(splitter, replacement)
          html = Internals.rebuild_html(splitter, replacement)
          # Pandoc sometimes leaves newlines on list items and `<ul>` opening
          # and closing tags when it converts Markdown to Ruby; we can safely
          # strip hose.
          Internals.cleanup_lists_after_pandoc html
        end
      end # class Prolog::Services::ReplaceContent::Converter
    end # class Prolog::Services::ReplaceContent
  end
end
