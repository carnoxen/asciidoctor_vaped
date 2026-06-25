# frozen_string_literal: true

require_relative "delimited_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class Quote < DelimitedNode
        def delimiter = "____"
        def context_name = :quote
      end
    end
  end
end
