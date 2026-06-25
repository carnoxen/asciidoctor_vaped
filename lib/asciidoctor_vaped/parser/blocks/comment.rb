# frozen_string_literal: true

require_relative "base_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class Comment < BaseNode
        def match?(context)
          context.reader.peek&.start_with?("//")
        end

        def parse(context)
          context.reader.peek == "////" ? context.reader.read_delimited("////") : context.reader.read
        end
      end
    end
  end
end
