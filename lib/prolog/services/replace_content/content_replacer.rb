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

        # rubocop:disable Metrics/LineLength
        #
        # Why not just use
        #   source.partition(marker.begin).first
        # (and similar code for #tail) and be done with it? Because our CI
        # server gives us a *weird* error with that code:
        #
        #   Minitest::Assertion: --- expected
        #   +++ actual
        #   @@ -1 +1 @@
        #   -"<p>This is replacement content for the test.</p>"
        #   +"<p>This is <em>source</em> material for the test.<br/>replacement content</p>"
        #
        # We've discovered some moving-part breakage along the way (see issue
        # 3096 for docker/machine on GitHub), but those aren't the problem we're
        # really trying to solve here. This is.
        #
        # rubocop:enable Metrics/LineLength
        def head
          marker_begin = marker.begin
          index = source.index marker_begin
          logger.trace 'In #head', index: index, source: source,
                                   marker_begin: marker_begin
          source[0...index]
        end

        def tail
          end_marker = marker.end
          index = source.index(end_marker) + end_marker.length
          logger.trace 'In #tail', index: index, source: source,
                                   marker_end: end_marker
          source[index..-1]
        end
      end # class Prolog::Services::ReplaceContent::ContentReplacer
    end # class Prolog::Services::ReplaceContent
  end
end
