# frozen_string_literal: true

require_relative "delimited_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class Listing < DelimitedNode
        DELIMITER = "----"
        CONTEXT = :listing
      end
    end
  end
end
