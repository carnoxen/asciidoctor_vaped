# frozen_string_literal: true

require_relative "../common/base_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class Admonition < BaseNode
        PATTERN = /\A(NOTE|TIP|IMPORTANT|WARNING|CAUTION):\s+(.+)\z/

        def parse(context)
          name, text = context.reader.read.match(PATTERN).captures
          context.append AST::Element.new(:admonition, attributes: { name: }, children: Inline.parse(text))
        end
      end
    end
  end
end
