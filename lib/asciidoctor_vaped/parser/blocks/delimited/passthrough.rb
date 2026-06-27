# frozen_string_literal: true

require_relative "delimited_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class Passthrough < DelimitedNode
        CONTEXT = :pass

        def delimiters = %w[+++ ++++]
      end
    end
  end
end
