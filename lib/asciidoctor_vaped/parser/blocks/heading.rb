# frozen_string_literal: true

require_relative "common/base_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class Heading < BaseNode
        PATTERN = /\A(=+)\s+(.+)\z/

        def parse(context)
          markers, title = context.reader.read.match(PATTERN).captures
          level = [markers.length - 1, 1].max
          context.open_section AST::Element.new(:section, attributes: { level: }, children: Inline.parse(title))
        end
      end
    end
  end
end
