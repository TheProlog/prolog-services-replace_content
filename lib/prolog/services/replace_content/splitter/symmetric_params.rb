# frozen_string_literal: true

require_relative './splitter_params'

module Prolog
  module Services
    # Replaces content within an HTML string based on endpoints and content.
    class ReplaceContent
      module Splitter
        # Builds splitter params for symmetric splitter; same marker text before
        # and after selected content.
        class SymmetricSplitterParams < SplitterParams
          def initialize(content, endpoints, marker)
            super content, endpoints
            add(marker: marker)
            self
          end
        end # class ...::ReplaceContent::Splitter::SymmetricSplitterParams
      end
    end # class Prolog::Services::ReplaceContent::SplitterParams
  end
end
