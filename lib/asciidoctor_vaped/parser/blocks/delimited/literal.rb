# frozen_string_literal: true

require_relative "delimited_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class Literal < DelimitedNode
        DELIMITER = "...."
        CONTEXT = :literal
      end
    end
  end
end
