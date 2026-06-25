# frozen_string_literal: true

require_relative "base_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class DelimitedNode < BaseNode
        def match?(context)
          context.reader.peek == delimiter
        end

        def parse(context)
          lines = context.reader.read_delimited(delimiter)
          context.append AST::Node.new(context_name, text: lines.join("\n"), attributes:)
        end

        def attributes
          {}
        end
      end
    end
  end
end
