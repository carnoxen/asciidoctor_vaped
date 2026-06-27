# frozen_string_literal: true

require_relative "delimited_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class Quote < CompoundDelimitedNode
        DELIMITER = "____"
        CONTEXT = :quote
      end
    end
  end
end
