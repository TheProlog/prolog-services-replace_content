# frozen_string_literal: true

module Prolog
  module Services
    # Replaces content within an HTML string based on endpoints and content.
    class ReplaceContent
      module Splitter
        # Simple class to move splitter parameter munging out of ReplaceContent.
        class SplitterParams
          def initialize(content, endpoints)
            @params = { content: content, endpoints: endpoints }
            self
          end

          def add(**extra_params)
            @params.merge! extra_params
            self
          end

          def to_hash
            @params
          end
        end # class Prolog::Services::ReplaceContent::Splitter::SplitterParams
      end
    end # class Prolog::Services::ReplaceContent::SplitterParams
  end
end
