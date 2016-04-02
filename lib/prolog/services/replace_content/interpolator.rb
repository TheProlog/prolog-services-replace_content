# frozen_string_literal: true

require_relative 'range_splitter'

module Prolog
  module Services
    # Replaces content within an HTML string based on endpoints and content.
    class ReplaceContent
      # Interpolates two marker strings within a three-section content string.
      # The content string may be either Markdown or HTML; the marker strings
      # are HTML (ergo valid Markdown) tag pairs.
      class Interpolator
        # Methods that neither affect nor are affected by instance state.
        module Internals
          def self.build_splitter(content, endpoints)
            RangeSplitter.new content: content, endpoints: endpoints
          end

          def self.cleanup(parts, separators)
            parts.zip(separators).flatten.compact
          end
        end
        private_constant :Internals

        def initialize(content:, endpoints:, marker:)
          @splitter = Internals.build_splitter content, endpoints
          @marker = marker
          self
        end

        def to_a
          Internals.cleanup splitter.parts, markers
        end

        private

        attr_reader :marker, :splitter

        def markers
          [marker.begin, marker.end]
        end
      end # class Prolog::Services::ReplaceContent::Interpolator
    end # class Prolog::Services::ReplaceContent
  end
end
