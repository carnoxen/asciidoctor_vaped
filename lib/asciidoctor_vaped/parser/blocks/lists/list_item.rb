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
          context.append AST::Node.new(:list_item, text: context.reader.read.sub(@pattern, ""), inline: true)
        end
      end
    end
  end
end
