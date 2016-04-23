# frozen_string_literal: true

module Prolog
  module Services
    # Replaces content within an HTML string based on endpoints and content.
    class ReplaceContent
      module Splitter
        # A "symmetric" splitter inserts the same marker text before and after
        # the selected range. This defaults to an empty string, but can be any
        # simple string.
        class Symmetric
          DEFAULT_MARKER = ''

          attr_reader :inner, :source

          # Methods neither affecting nor affected by instance state.
          module Internals
            def self.build_inner(content, endpoints, marker)
              [marker, marker].join content[endpoints]
            end
          end
          private_constant :Internals

          # Simplemindedly splits content string based on endpoints, returning
          # bounding segments (not including substring *within* endpoints).
          # Nobody should care what the marker actually is; just that it wrapps
          # the `inner` value and makes the combination unique within the
          # content.
          class Parts
            def self.parts(content, endpoints)
              _twiddle(_split(content.dup, endpoints))
            end

            def self._marker
              'z|q|x' * 8
            end

            def self._split(working, endpoints)
              marker = _marker
              working[endpoints] = marker
              working.split marker
            end

            def self._twiddle(items)
              return ['', ''] if items.empty?
              items
            end
          end # class Prolog::Services::ReplaceContent::ContentSplitter::Parts

          def initialize(content:, endpoints:, marker: DEFAULT_MARKER)
            @inner = Internals.build_inner(content, endpoints, marker)
            @source = rebuild_source(content, endpoints)
            self
          end

          private

          def rebuild_source(content, endpoints)
            Parts.parts(content, endpoints).join inner
          end
        end # class Prolog::Services::ReplaceContent::Splitter::Symmetric
      end
    end # class Prolog::Services::ReplaceContent
  end
end
