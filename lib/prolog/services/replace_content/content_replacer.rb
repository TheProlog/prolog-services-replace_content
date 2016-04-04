# frozen_string_literal: true

require 'semantic_logger'

module Prolog
  module Services
    # Replaces content within an HTML string based on endpoints and content.
    class ReplaceContent
      # Replace content delimited by marker tag pairs with other content.
      class ContentReplacer
        include SemanticLogger::Loggable

        def initialize(source:, marker:)
          @marker = marker
          @source = source
        end

        def with(replacement)
          logger.trace 'Entering #with', head: head, tail: tail,
                                         replacement: replacement
          [head, tail].join replacement
        end

        private

        attr_reader :marker, :source

        def head
          partition_at(marker.begin).first
        end

        def partition_at(index)
          source.partition(index)
        end

        def tail
          partition_at(marker.end).last
        end
      end # class Prolog::Services::ReplaceContent::ContentReplacer
    end # class Prolog::Services::ReplaceContent
  end
end
