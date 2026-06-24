# frozen_string_literal: true

module AsciidoctorVaped
  module AST
    class Node
      attr_reader :context, :attributes, :blocks
      attr_accessor :parent, :text

      def initialize(context, text: nil, attributes: {})
        @context = context
        @text = text
        @attributes = attributes
        @blocks = []
      end

      def <<(block)
        block.parent = self
        blocks << block
        block
      end

      def sections
        blocks.select { |block| block.context == :section }
      end

      def to_h
        {
          context:,
          text:,
          attributes:,
          blocks: blocks.map(&:to_h)
        }
      end
    end
  end
end
