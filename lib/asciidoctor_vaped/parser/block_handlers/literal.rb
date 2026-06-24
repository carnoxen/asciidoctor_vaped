# frozen_string_literal: true

require_relative "delimited_block"

module AsciidoctorVaped
  module Parser
    module BlockHandlers
      class Literal < DelimitedBlock
        def delimiter = "...."
        def context_name = :literal
      end
    end
  end
end
