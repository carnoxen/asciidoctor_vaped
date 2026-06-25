# frozen_string_literal: true

require_relative "list_base"

module AsciidoctorVaped
  module Parser
    module Blocks
      class OrderedList < ListBase
        def match?(context)
          context.reader.peek&.match?(pattern)
        end

        private

        def list_context = :olist
        def pattern = /\A\.\s+/
      end
    end
  end
end
