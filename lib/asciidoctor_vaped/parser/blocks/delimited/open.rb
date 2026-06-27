# frozen_string_literal: true

require_relative "delimited_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class Open < CompoundDelimitedNode
        DELIMITER = "--"
        CONTEXT = :open
      end
    end
  end
end
