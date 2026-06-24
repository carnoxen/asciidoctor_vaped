# frozen_string_literal: true

module AsciidoctorVaped
  module Parser
    module BlockHandlers
      class Base
        def initialize(successor = nil)
          @successor = successor
        end

        def handle(context)
          return parse(context) if match?(context)

          @successor&.handle(context)
        end
      end
    end
  end
end
