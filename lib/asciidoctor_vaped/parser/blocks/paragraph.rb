# frozen_string_literal: true

require_relative "common/base_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class Paragraph < BaseNode
        def match?(_context)
          true
        end

        def parse(context)
          lines = context.reader.read_until_blank
          context.append AST::Node.new(:paragraph, text: lines.join("\n"), inline: true)
        end
      end
    end
  end
end
