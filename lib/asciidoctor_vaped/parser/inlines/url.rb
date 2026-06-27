# frozen_string_literal: true

module AsciidoctorVaped
  module Parser
    module Inlines
      class Url < BaseNode
        PATTERN = %r{https?://[^\s<]+}.freeze

        def self.node(token)
          Inline.container(:link, token, target: token)
        end
      end
    end
  end
end
