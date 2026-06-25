# frozen_string_literal: true

module AsciidoctorVaped
  module AST
    class Node
      attr_reader :context, :attributes, :children
      attr_accessor :parent, :text

      def initialize(context, text: nil, attributes: {}, children: [], inline: false)
        @context = context
        @text = text
        @attributes = attributes
        @children = []
        append_children(children)
        parse_inline if inline
      end

      def <<(node)
        append(node)
      end

      def append(node)
        node.parent = self
        children << node
        node
      end

      def append_children(nodes)
        nodes.each { |node| append(node) }
        self
      end

      def parse_inline
        append_children(Parser::Inline.parse(text))
      end

      def sections
        children.select { |child| child.context == :section }
      end

      def to_h
        {
          context:,
          text:,
          attributes:,
          children: children.map(&:to_h)
        }
      end
    end
  end
end
