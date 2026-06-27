# frozen_string_literal: true

require_relative "list_base"

module AsciidoctorVaped
  module Parser
    module Blocks
      class UnorderedList < ListBase
        CONTEXT = :ulist
        PATTERN = /\A[*-]\s+/
      end
    end
  end
end
