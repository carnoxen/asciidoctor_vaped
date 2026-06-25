# frozen_string_literal: true

module AsciidoctorVaped
  module Parser
    module Inlines
      class Url
        PATTERN = %r{https?://[^\s<]+}.freeze

        def self.match(text)
          PATTERN.match(text)
        end

        def self.node(token)
          AST::Node.new(:link, text: token, attributes: { target: token })
        end
      end
    end
  end
end
