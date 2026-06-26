# frozen_string_literal: true

module AsciidoctorVaped
  module AST
    class Node
      TEXT_CONTEXTS = %i[text link strong emphasis monospace].freeze

      attr_reader :children
      attr_accessor :parent

      def initialize(children: [])
        @children = []
        append_children(children)
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

      def text
        children.select { |child| TEXT_CONTEXTS.include?(child.context) }.map(&:text).join
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
