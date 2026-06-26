# frozen_string_literal: true

require_relative "delimited_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class Open < DelimitedNode
        def delimiter = "--"
        def default_context_name = :open

        private

        def compound?(_context) = true
      end
    end
  end
end
