# frozen_string_literal: true

require_relative "base_block"

module AsciidoctorVaped
  module Parser
    module BlockHandlers
      class Paragraph < BaseBlock
        def match?(_context)
          true
        end

        def parse(context)
          lines = context.reader.read_until_blank
          context.append AST::Node.new(:paragraph, text: lines.join("\n"))
        end
      end
    end
  end
end
