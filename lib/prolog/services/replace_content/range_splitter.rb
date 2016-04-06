# frozen_string_literal: true

require 'semantic_logger'

module Prolog
  module Services
    # Replaces content within an HTML string based on endpoints and content.
    class ReplaceContent
      # Splits a content string based on endpoint index values.
      class RangeSplitter
        # Methods neither affecting nor affected by instance state
        module Internals
          def self.after(string, index)
            string[index..-1]
          end

          def self.between(string, endpoints)
            string[endpoints.begin...endpoints.end]
          end

          def self.up_to(string, index)
            string[0...index]
          end
        end
        private_constant :Internals
        include SemanticLogger::Loggable

        def initialize(content:, endpoints:)
          logger.trace 'RangeSplitter#initialize', content: content,
                                                   endpoints: endpoints
          @content = content.dup # content#clone will produce a frozen string
          @endpoints = endpoints
          self
        end

        def parts
          ret = [begin_part, middle_part, end_part]
          logger.trace 'RangeSplitter#parts', ret: ret
          ret
        end

        private

        attr_reader :content, :endpoints

        def begin_part
          Internals.up_to content, endpoints.begin
        end

        def end_part
          Internals.after content, endpoints.end
        end

        def middle_part
          Internals.between content, endpoints
        end
      end # class Prolog::Services::ReplacementContent::RangeSplitter
    end # class Prolog::Services::ReplacementContent
  end
end
