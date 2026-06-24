# frozen_string_literal: true

require_relative "base"

module AsciidoctorVaped
  module Parser
    module BlockHandlers
      class BlankLine < Base
        def match?(context)
          context.reader.peek&.strip == ""
        end

        def parse(context)
          context.reader.skip_blank_lines
        end
      end
    end
  end
end
