# frozen_string_literal: true

module Prolog
  module Services
    # Replaces content within an HTML string based on endpoints and content.
    class ReplaceContent
      # Builds HTML for a "marker tag pair"
      class Marker
        def initialize(id_prefix: 'dummy', tag: :span)
          @id_prefix = id_prefix
          @tag = tag
          self
        end

        def begin
          tag_pair :begin
        end

        def end
          tag_pair :end
        end

        private

        def tag_pair(which_end)
          %(<#{@tag} id="#{@id_prefix}-#{which_end}"></#{@tag}>)
        end
      end # class Prolog::Services::ReplaceContent::Interpolator
    end # class Prolog::Services::ReplaceContent
  end
end
