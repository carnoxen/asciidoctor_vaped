# frozen_string_literal: true

require_relative "../common/base_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class ListItem < BaseNode
        def initialize(successor = nil, pattern:)
          super(successor)
          @pattern = pattern
        end

        def match?(context)
          context.reader.peek&.match?(@pattern)
        end

        def parse(context)
          context.append AST::Element.new(:list_item, children: Inline.parse(context.reader.read.sub(@pattern, "")))
        end
      end
    end
  end
end
