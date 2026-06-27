# frozen_string_literal: true

require_relative "delimited_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class Example < CompoundDelimitedNode
        DELIMITER = "===="
        CONTEXT = :example
      end
    end
  end
end
