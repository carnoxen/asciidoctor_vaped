# frozen_string_literal: true

require_relative "delimited_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class Literal < DelimitedNode
        def delimiter = "...."
        def default_context_name = :literal
      end
    end
  end
end
