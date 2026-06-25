# frozen_string_literal: true

require_relative "delimited_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class Passthrough < DelimitedNode
        def delimiters = %w[+++ ++++]
        def default_context_name = :pass
      end
    end
  end
end
