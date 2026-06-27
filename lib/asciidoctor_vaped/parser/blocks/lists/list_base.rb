# frozen_string_literal: true

require_relative "../../common/base_node"
require_relative "list_item"

module AsciidoctorVaped
  module Parser
    module Blocks
      class ListBase < BaseNode
        def parse(context)
          list = AST::Element.new(list_context)
          item_context = context.nested(list)
          item_chain.handle(item_context) while match?(context)
          context.append(list)
        end

        private

        def list_context
          self.class::CONTEXT
        end

        def item_chain
          Blocks.chain([[ListItem, { pattern: }]])
        end
      end
    end
  end
end
