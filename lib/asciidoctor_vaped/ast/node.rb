# frozen_string_literal: true

module AsciidoctorVaped
  module AST
    class Node
      TEXT_CONTEXTS = %i[link strong emphasis monospace].freeze

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
        node.parent = self unless node.is_a?(String)
        children << node
        node
      end

      def append_children(nodes)
        nodes.each { |node| append(node) }
        self
      end

      def text
        children.filter_map do |child|
          if child.is_a?(String)
            child
          elsif TEXT_CONTEXTS.include?(child.context)
            child.text
          end
        end.join
      end

      def parse_inline
        append_children(Parser::Inline.parse(text))
      end

      def sections
        children.select { |child| child.respond_to?(:context) && child.context == :section }
      end

      def to_h
        {
          context:,
          text:,
          **(respond_to?(:attributes) ? { attributes: } : {}),
          children: children.map { |child| child.respond_to?(:to_h) ? child.to_h : child }
        }
      end
    end
  end
end
