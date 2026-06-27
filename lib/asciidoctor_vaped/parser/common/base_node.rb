# frozen_string_literal: true

module AsciidoctorVaped
  module Parser
    class BaseNode
      def self.match(text)
        self::PATTERN.match(text)
      end

      def initialize(successor = nil)
        @successor = successor
      end

      def handle(context)
        return parse(context) if match?(context)

        @successor&.handle(context)
      end

      def match?(context)
        context.reader.peek&.match?(pattern)
      end

      private

      def pattern
        self.class::PATTERN
      end
    end

    class QuotedNode < BaseNode
      def self.node(token)
        Inline.container(self::CONTEXT, token[1...-1])
      end
    end
  end
end
