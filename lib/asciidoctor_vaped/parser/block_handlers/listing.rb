# frozen_string_literal: true

require_relative "delimited_block"

module AsciidoctorVaped
  module Parser
    module BlockHandlers
      class Listing < DelimitedBlock
        def delimiter = "----"
        def context_name = :listing
      end
    end
  end
end
