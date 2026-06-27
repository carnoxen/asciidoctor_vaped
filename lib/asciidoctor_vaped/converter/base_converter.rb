# frozen_string_literal: true

require_relative "../parser/inline"

module AsciidoctorVaped
  module Converter
    class BaseConverter
      NODE_RENDERERS = {
        section: :section,
        paragraph: :paragraph,
        listing: :listing,
        literal: :literal,
        ulist: :list,
        olist: :list,
        table: :table,
        admonition: :admonition,
        example: :titled_block,
        quote: :titled_block,
        sidebar: :titled_block,
        pass: :pass,
        open: :open,
        text: :text,
        link: :link,
        strong: :inline,
        emphasis: :inline,
        monospace: :inline
      }.freeze
      TEXT_NODE_CONTEXTS = %i[text link strong emphasis monospace].freeze

      def initialize(options = {})
        @options = options
      end

      def convert(_document)
        raise NotImplementedError, "#{self.class} must implement #convert"
      end

      private

      def convert_node(node)
        send(NODE_RENDERERS.fetch(node.context, :fallback), node)
      end

      def paragraph(node)
        tag(element_name(:paragraph), render_text(node))
      end

      def literal(node)
        tag(element_name(:literal), escape(node.text))
      end

      def pass(node)
        node.text.to_s
      end

      def open(node)
        render_content(node)
      end

      def text(node)
        escape(node.text)
      end

      def link(node)
        tag(element_name(:link), render_text(node), link_attrs(node))
      end

      def inline(node)
        content = node.context == :monospace ? escape(node.text) : render_text(node)
        tag(element_name(node.context), content, element_attrs(node.context))
      end

      def fallback(node)
        render_text(node.text.to_s)
      end

      def title(node)
        return "" unless node.attributes[:title]

        tag(element_name(:title), render_text(node.attributes[:title]), element_attrs(:title))
      end

      def element_name(name)
        self.class::ELEMENT_NAMES.fetch(name)
      end

      def element_attrs(_context)
        {}
      end

      def escape(value)
        value.to_s
          .gsub("&", "&amp;")
          .gsub("<", "&lt;")
          .gsub(">", "&gt;")
          .gsub('"', "&quot;")
      end

      def escape_attr(value)
        escape(value)
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
