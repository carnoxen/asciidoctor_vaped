# frozen_string_literal: true

require_relative "list_base"

module AsciidoctorVaped
  module Parser
    module Blocks
      class OrderedList < ListBase
        private

        def list_context = :olist
        def pattern = /\A\.\s+/
      end
    end
  end
end
