# frozen_string_literal: true

require_relative "delimited_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class Sidebar < CompoundDelimitedNode
        DELIMITER = "****"
        CONTEXT = :sidebar
      end
    end
  end
end
