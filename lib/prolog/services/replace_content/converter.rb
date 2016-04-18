# frozen_string_literal: true

require 'ox'

module Prolog
  module Services
    # Replaces content within an HTML string based on endpoints and content.
    class ReplaceContent
      # Converts HTML or Markdown to HTML with "inner" content delimited.
      class Converter
        def self.convert(splitter, replacement)
          html = splitter.source
          html.sub!(splitter.inner, replacement)
          html
        end
      end # class Prolog::Services::ReplaceContent::Converter
    end # class Prolog::Services::ReplaceContent
  end
end
