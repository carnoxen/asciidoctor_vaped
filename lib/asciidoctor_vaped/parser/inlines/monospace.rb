# frozen_string_literal: true

module AsciidoctorVaped
  module Parser
    module Inlines
      class Monospace
        PATTERN = /`[^`]+`/.freeze

        def self.match(text)
          PATTERN.match(text)
        end

        def self.node(token)
          AST::Node.new(:monospace, text: token[1...-1])
        end
      end
    end
  end
end
