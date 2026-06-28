# frozen_string_literal: true

require_relative "../../common/base_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class ListItem < BaseNode
        def self.build(text)
          AST::Element.new(:list_item, children: Inline.parse(text))
        end

        def initialize(successor = nil, pattern:)
          super(successor)
          @pattern = pattern
        end

        def parse(context)
          context.append self.class.build(context.reader.read.sub(@pattern, ""))
        end

        private

        attr_reader :pattern
      end
    end
  end
end
