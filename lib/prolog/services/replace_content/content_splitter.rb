# frozen_string_literal: true

module Prolog
  module Services
    # Replaces content within an HTML string based on endpoints and content.
    class ReplaceContent
      # Extracts parts of source content, wrapping inner section with markers.
      # The whole justification for this class is to build the readable
      # attributes.
      class ContentSplitter
        attr_reader :inner, :source

        # Methods neither affecting nor affected by instance state.
        module Internals
          def self.build_inner(content, endpoints)
            marker = 'zqxzqxzqx'
            [marker, marker].join content[endpoints]
          end
        end
        private_constant :Internals

        # Simplemindedly splits content string based on endpoints, returning
        # bounding segments (not including substring *within* endpoints). Nobody
        # should care what the marker actually is; just that it wrapps the
        # `inner` value and makes the combination unique within the content.
        class Parts
          def self.parts(content, endpoints)
            [content[0...endpoints.begin], content[endpoints.end..-1]]
          end
        end # class Prolog::Services::ReplaceContent::ContentSplitter::Parts

        def initialize(content:, endpoints:)
          @inner = Internals.build_inner(content, endpoints)
          @source = rebuild_source(content, endpoints)
          self
        end

        private

        def rebuild_source(content, endpoints)
          Parts.parts(content, endpoints).join inner
        end
      end # class Prolog::Services::ReplaceContent::ContentSplitter
    end # class Prolog::Services::ReplaceContent
  end
end
