# frozen_string_literal: true

require_relative "base_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class Section < BaseNode
        PATTERN = /\A(=+)\s+(.+)\z/

        def parse(context)
          markers, title = context.reader.read.match(PATTERN).captures
          level = [markers.length - 1, 1].max
          context.open_section AST::Node.new(:section, text: title, attributes: { level: }, inline: true)
        end
      end
    end
  end
end
