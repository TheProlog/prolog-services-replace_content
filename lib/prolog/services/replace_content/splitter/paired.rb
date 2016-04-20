# frozen_string_literal: true

module Prolog
  module Services
    # Replaces content within an HTML string based on endpoints and content.
    class ReplaceContent
      module Splitter
        # A "paired" splitter inserts an empty pair of HTML tags before the
        # selected content, and another such empty tag pair afterwards. The tag
        # pairs each have an ID attribute string which ends in '-begin' for the
        # tag pair before the selection, and '-end' for the tag pair after the
        # content. The default for the tag is the anchor tag (:a), though that
        # may be changed by specifying a synbolic `tag` parameter (such as
        # :span). The default text before the '-begin'/'-end' text in the ID
        # attribute strings is 'selection'; that may similary be changed by
        # specifying the `identifier` parameter to the initialiser.
        class Paired
          def initialize(content:, endpoints:, tag: :a, identifier: 'selection')
            @content = content
            @endpoints = endpoints
            @identifier = identifier
            @tag = tag
            self
          end

          def inner
            content[endpoints]
          end

          def source
            parts.join
          end

          private

          attr_reader :content, :endpoints, :identifier, :tag

          def leading_content
            content[0...endpoints.begin]
          end

          def trailing_content
            content[endpoints.end..-1]
          end

          def leading_marker
            marker :begin
          end

          def trailing_marker
            marker :end
          end

          def marker(which_end)
            format_str = %(<%s id="%s-%s"></%s>)
            format format_str, tag, identifier, which_end, tag
          end

          def parts
            [leading_content, leading_marker, inner, trailing_marker,
             trailing_content]
          end
        end # class Prolog::Services::ReplaceContent::Splitter::Paired
      end
    end # class Prolog::Services::ReplaceContent
  end
end
