# frozen_string_literal: true

require_relative "list_base"

module AsciidoctorVaped
  module Parser
    module Blocks
      class UnorderedList < ListBase
        private

        def list_context = :ulist
        def pattern = /\A[*-]\s+/
      end
    end
  end
end
