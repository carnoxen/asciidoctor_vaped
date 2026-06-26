# frozen_string_literal: true

module AsciidoctorVaped
  module Converter
    module Node
      NODE_RENDERERS = {
        section: :section,
        paragraph: :paragraph,
        listing: :listing,
        literal: :literal,
        ulist: :list,
        olist: :list,
        table: :table,
        admonition: :admonition,
        example: :example,
        quote: :quote,
        sidebar: :sidebar,
        pass: :pass,
        open: :open,
        text: :text,
        link: :link,
        strong: :strong,
        emphasis: :emphasis,
        monospace: :monospace
      }.freeze

      private

      def convert_node(node)
        send(NODE_RENDERERS.fetch(node.context, :fallback), node)
      end

      def paragraph(node)
        tag(paragraph_tag, render_text(node))
      end

      def literal(node)
        tag(literal_tag, escape(node.text))
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
        tag(link_tag, render_text(node), link_attrs(node))
      end

      def strong(node)
        tag(strong_tag, render_text(node), strong_attrs)
      end

      def emphasis(node)
        tag(emphasis_tag, render_text(node), emphasis_attrs)
      end

      def monospace(node)
        tag(monospace_tag, escape(node.text), monospace_attrs)
      end

      def fallback(node)
        render_text(node.text.to_s)
      end

      def title(node)
        return "" unless node.attributes[:title]

        tag(title_tag, render_text(node.attributes[:title]), title_attrs)
      end

      def strong_attrs
        {}
      end

      def emphasis_attrs
        {}
      end

      def monospace_attrs
        {}
      end
    end
  end
end
