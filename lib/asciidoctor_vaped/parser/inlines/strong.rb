# frozen_string_literal: true

module AsciidoctorVaped
  module Parser
    module Inlines
      class Strong < QuotedNode
        PATTERN = /\*[^*]+\*/.freeze
        CONTEXT = :strong
      end
    end
  end
end
