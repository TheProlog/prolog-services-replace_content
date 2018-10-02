# frozen_string_literal: true

require_relative './paired'
require_relative './symmetric'
require_relative './splitter_params'
require_relative './paired_params'
require_relative './symmetric_params'

module Prolog
  module Services
    # Replaces content within an HTML string based on endpoints and content.
    class ReplaceContent
      module Splitter
        # Should we use a symmetric or paired (identifier) splitter?
        class Factory
          # Methods independent of any instance state.
          module Internals
            def self.splitter_with_markers(data)
              Paired.new _splitter_marker_params(data)
            end

            def self.symmetric_splitter(data, marker)
              Symmetric.new _symmetric_marker_params(data, marker)
            end

            def self._build_splitter_marker_params(data)
              markers = data.markers
              identifier = _splitter_identifier_from markers
              [data.content, data.endpoints, markers[0], identifier]
            end

            def self._splitter_identifier_from(markers)
              markers[1] || Paired::DEFAULT_ID
            end

            def self._splitter_marker_params(data)
              params = _build_splitter_marker_params(data)
              PairedSplitterParams.new(*params)
            end

            def self._symmetric_marker_params(data, marker)
              SymmetricSplitterParams.new data.content, data.endpoints, marker
            end
          end # module Internals
          private_constant :Internals

          def self.call(data, marker)
            return Internals.splitter_with_markers(data) if data.markers

            Internals.symmetric_splitter data, marker
          end
        end # class Prolog::Services::ReplaceContent::Splitter::Factory
      end
    end # class Prolog::Services::ReplaceContent
  end
end
