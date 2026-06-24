# frozen_string_literal: true

require_relative "base"

module AsciidoctorVaped
  module Parser
    module BlockHandlers
      class AttributeEntry < Base
        PATTERN = /\A:([^:\s][^:]*):\s*(.*)\z/

        def match?(context)
          context.reader.peek&.match?(PATTERN)
        end

        def parse(context)
          name, value = context.reader.read.match(PATTERN).captures
          context.document.register_attribute(name, value)
        end
      end
    end
  end
end
