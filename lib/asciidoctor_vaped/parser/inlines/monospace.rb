# frozen_string_literal: true

module AsciidoctorVaped
  module Parser
    module Inlines
      class Monospace < QuotedNode
        PATTERN = /`[^`]+`/.freeze
        CONTEXT = :monospace
      end
    end
  end
end
