# frozen_string_literal: true

require_relative "base_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class Admonition < BaseNode
        PATTERN = /\A(NOTE|TIP|IMPORTANT|WARNING|CAUTION):\s+(.+)\z/

        def match?(context)
          context.reader.peek&.match?(PATTERN)
        end

        def parse(context)
          name, text = context.reader.read.match(PATTERN).captures
          context.append AST::Node.new(:admonition, text:, attributes: { name: }, inline: true)
        end
      end
    end
  end
end
