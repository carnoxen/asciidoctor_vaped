# frozen_string_literal: true

require_relative "list_base"

module AsciidoctorVaped
  module Parser
    module BlockHandlers
      class UnorderedList < ListBase
        def match?(context)
          context.reader.peek&.match?(pattern)
        end

        private

        def list_context = :ulist
        def pattern = /\A[*-]\s+/
      end
    end
  end
end
