# frozen_string_literal: true

module AsciidoctorVaped
  module Parser
    module Blocks
      class BaseNode
        def initialize(successor = nil)
          @successor = successor
        end

        def handle(context)
          return parse(context) if match?(context)

          @successor&.handle(context)
        end

        def match?(context)
          context.reader.peek&.match?(self.class::PATTERN)
        end
      end
    end
  end
end
