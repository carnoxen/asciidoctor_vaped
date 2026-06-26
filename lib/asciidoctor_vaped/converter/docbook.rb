# frozen_string_literal: true

module AsciidoctorVaped
  module Converter
    class DocBook < BaseConverter
      include Converter::Node

      def convert(document)
        title = document.doctitle || "Untitled"
        body = render_nodes(document)
        %(<article>\n<title>#{escape title}</title>\n#{body}\n</article>)
      end

      private

      def paragraph_tag
        "para"
      end

      def section(node)
        body = render_nodes(node)
        %(<section>\n<title>#{render_text node}</title>\n#{body}\n</section>)
      end

      def listing(node)
        language = node.attributes[:language]
        attrs = language ? %( language="#{escape_attr language}") : ""
        "<programlisting#{attrs}>#{escape node.text}</programlisting>"
      end

      def literal_tag
        "literallayout"
      end

      def open(node)
        render_text(node.text.to_s)
      end

      def list(node)
        tag_name = node.context == :olist ? "orderedlist" : "itemizedlist"
        items = node.children.map { |item| "<listitem><para>#{render_text item}</para></listitem>" }.join("\n")
        "<#{tag_name}>\n#{items}\n</#{tag_name}>"
      end

      def table(node)
        rows = node.children.map do |row|
          cells = row.children.map { |cell| "<entry>#{render_text cell}</entry>" }.join
          "<row>#{cells}</row>"
        end.join("\n")
        "<informaltable>\n<tgroup cols=\"#{column_count node}\">\n<tbody>\n#{rows}\n</tbody>\n</tgroup>\n</informaltable>"
      end

      def admonition(node)
        name = node.attributes.fetch(:name, "note").to_s.downcase
        "<#{name}><para>#{render_text node}</para></#{name}>"
      end

      def example(node)
        titled_node("example", node)
      end

      def quote(node)
        titled_node("blockquote", node)
      end

      def sidebar(node)
        titled_node("sidebar", node)
      end

      def titled_node(tag_name, node)
        title = node.attributes[:title] ? "<title>#{render_text node.attributes[:title]}</title>\n" : ""
        "<#{tag_name}>\n#{title}<para>#{render_text node}</para>\n</#{tag_name}>"
      end

      def column_count(node)
        node.children.map { |row| row.children.length }.max || 1
      end

      def title_tag
        "title"
      end

      def title_attrs
        {}
      end

      def link_tag
        "link"
      end

      def link_attrs(node)
        { "xlink:href": node.attributes.fetch(:target) }
      end

      def strong_tag
        "emphasis"
      end

      def strong_attrs
        { role: "strong" }
      end

      def emphasis_tag
        "emphasis"
      end

      def monospace_tag
        "literal"
      end
    end
  end
end
