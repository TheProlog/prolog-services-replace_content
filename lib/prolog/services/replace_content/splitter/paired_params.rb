# frozen_string_literal: true

require_relative './splitter_params'

module Prolog
  module Services
    # Replaces content within an HTML string based on endpoints and content.
    class ReplaceContent
      module Splitter
        # Builds splitter params for symmetric splitter; same marker text before
        # and after selected content.
        class PairedSplitterParams < SplitterParams
          def initialize(content, endpoints, tag, identifier)
            super content, endpoints
            add(tag: tag, identifier: identifier)
            self
          end
        end # class ...::ReplaceContent::Splitter::PairedSplitterParams
      end
    end # class Prolog::Services::ReplaceContent::SplitterParams
  end
end
