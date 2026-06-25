# frozen_string_literal: true

require_relative "delimited_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class Example < DelimitedNode
        def delimiter = "===="
        def context_name = :example
      end
    end
  end
end
