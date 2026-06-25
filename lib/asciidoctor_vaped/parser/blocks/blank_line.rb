# frozen_string_literal: true

require_relative "base_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class BlankLine < BaseNode
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
