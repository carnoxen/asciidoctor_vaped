# frozen_string_literal: true

module AsciidoctorVaped
  module Parser
    module Inlines
      class Emphasis < QuotedNode
        PATTERN = /_[^_]+_/.freeze
        CONTEXT = :emphasis
      end
    end
  end
end
