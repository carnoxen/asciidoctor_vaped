# frozen_string_literal: true

require_relative "base_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class BlockTitle < BaseNode
        PATTERN = /\A\.([^.\s].*)\z/

        def parse(context)
          context.pending_title = context.reader.read.match(PATTERN)[1]
        end
      end
    end
  end
end
