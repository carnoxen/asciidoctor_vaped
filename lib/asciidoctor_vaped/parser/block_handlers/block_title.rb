# frozen_string_literal: true

require_relative "base_block"

module AsciidoctorVaped
  module Parser
    module BlockHandlers
      class BlockTitle < BaseBlock
        PATTERN = /\A\.([^.\s].*)\z/

        def match?(context)
          context.reader.peek&.match?(PATTERN)
        end

        def parse(context)
          context.pending_title = context.reader.read.match(PATTERN)[1]
        end
      end
    end
  end
end
