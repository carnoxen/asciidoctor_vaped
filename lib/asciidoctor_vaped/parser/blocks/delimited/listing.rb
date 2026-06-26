# frozen_string_literal: true

require_relative "delimited_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class Listing < DelimitedNode
        def delimiter = "----"
        def default_context_name = :listing
      end
    end
  end
end
