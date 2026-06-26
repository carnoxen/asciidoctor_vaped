# frozen_string_literal: true

require_relative "node"

module AsciidoctorVaped
  module AST
    class Text < Node
      attr_accessor :value

      def initialize(value)
        @value = value
        super()
      end

      def context
        :text
      end

      def text
        value
      end

      def text=(value)
        self.value = value
      end

      def children
        []
      end

      def to_h
        {
          context:,
          text:,
          children: []
        }
      end
    end
  end
end
