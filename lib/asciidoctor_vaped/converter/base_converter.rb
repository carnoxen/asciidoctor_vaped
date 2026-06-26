# frozen_string_literal: true

require_relative "../parser/inline"

module AsciidoctorVaped
  module Converter
    class BaseConverter
      TEXT_NODE_CONTEXTS = %i[text link strong emphasis monospace].freeze

      def initialize(options = {})
        @options = options
      end

      def convert(_document)
        raise NotImplementedError, "#{self.class} must implement #convert"
      end

      private

      def escape(value)
        value.to_s
          .gsub("&", "&amp;")
          .gsub("<", "&lt;")
          .gsub(">", "&gt;")
          .gsub('"', "&quot;")
      end

      def escape_attr(value)
        escape(value).gsub('"', "&quot;")
      end

      def tag(name, content, attrs = {})
        "<#{name}#{html_attrs attrs}>#{content}</#{name}>"
      end

      def html_attrs(attrs)
        attrs.compact.map { |key, value| %( #{key}="#{escape_attr value}") }.join
      end

      def render_nodes(node)
        child_nodes(node).map { |child| convert_node(child) }.join("\n")
      end

      def render_content(node)
        child_nodes(node).empty? ? render_text(node) : render_nodes(node)
      end

      def render_text(value)
        nodes = value.respond_to?(:children) ? text_children(value) : Parser::Inline.parse(value)
        return escape(value.text.to_s) if nodes.empty? && value.respond_to?(:text)

        nodes.map { |node| convert_node(node) }.join
      end

      def child_nodes(node)
        node.children.reject { |child| text_node?(child) }
      end

      def text_children(node)
        node.children.select { |child| text_node?(child) }
      end

      def text_node?(node)
        TEXT_NODE_CONTEXTS.include?(node.context)
      end
    end
  end
end
