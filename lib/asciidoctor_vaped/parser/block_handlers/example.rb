# frozen_string_literal: true

require_relative "delimited_block"

module AsciidoctorVaped
  module Parser
    module BlockHandlers
      class Example < DelimitedBlock
        def delimiter = "===="
        def context_name = :example
      end
    end
  end
end
