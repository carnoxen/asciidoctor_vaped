# frozen_string_literal: true

module AsciidoctorVaped
  module Parser
    module Inlines
      class Link < BaseNode
        PATTERN = %r{https?://[^\s\[]+\[[^\]]+\]}.freeze

        def self.node(token)
          target, text = token.match(/\A(.+)\[([^\]]+)\]\z/).captures
          Inline.container(:link, text, target:)
        end
      end
    end
  end
end
