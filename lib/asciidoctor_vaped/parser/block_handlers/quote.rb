# frozen_string_literal: true

require_relative "delimited_block"

module AsciidoctorVaped
  module Parser
    module BlockHandlers
      class Quote < DelimitedBlock
        def delimiter = "____"
        def context_name = :quote
      end
    end
  end
end
