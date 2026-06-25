# frozen_string_literal: true

module AsciidoctorVaped
  module Parser
    module Inlines
      class Strong
        PATTERN = /\*[^*]+\*/.freeze

        def self.match(text)
          PATTERN.match(text)
        end

        def self.node(token)
          Inline.container(:strong, token[1...-1])
        end
      end
    end
  end
end
