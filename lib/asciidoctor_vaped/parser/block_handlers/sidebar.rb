# frozen_string_literal: true

require_relative "delimited_block"

module AsciidoctorVaped
  module Parser
    module BlockHandlers
      class Sidebar < DelimitedBlock
        def delimiter = "****"
        def context_name = :sidebar
      end
    end
  end
end
