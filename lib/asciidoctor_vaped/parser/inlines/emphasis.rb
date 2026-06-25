# frozen_string_literal: true

module AsciidoctorVaped
  module Parser
    module Inlines
      class Emphasis
        PATTERN = /_[^_]+_/.freeze

        def self.match(text)
          PATTERN.match(text)
        end

        def self.node(token)
          Inline.container(:emphasis, token[1...-1])
        end
      end
    end
  end
end
