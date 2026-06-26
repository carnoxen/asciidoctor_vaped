# frozen_string_literal: true

require_relative "delimited_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class Quote < DelimitedNode
        def delimiter = "____"
        def default_context_name = :quote

        private

        def compound?(_context) = true
      end
    end
  end
end
