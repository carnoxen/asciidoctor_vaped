# frozen_string_literal: true

require_relative "base_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class DocumentAttribute < BaseNode
        PATTERN = /\A:([^:\s][^:]*):\s*(.*)\z/

        def parse(context)
          name, value = context.reader.read.match(PATTERN).captures
          context.document.register_attribute(name, value)
        end
      end
    end
  end
end
