# frozen_string_literal: true

require_relative "base"

module AsciidoctorVaped
  module Parser
    module BlockHandlers
      class Section < Base
        PATTERN = /\A(=+)\s+(.+)\z/

        def match?(context)
          context.reader.peek&.match?(PATTERN)
        end

        def parse(context)
          markers, title = context.reader.read.match(PATTERN).captures
          level = [markers.length - 1, 1].max
          context.open_section AST::Node.new(:section, text: title, attributes: { level: })
        end
      end
    end
  end
end
