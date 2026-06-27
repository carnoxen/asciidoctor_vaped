# frozen_string_literal: true

module AsciidoctorVaped
  module Converter
    class DocBook < BaseConverter
      ELEMENT_NAMES = {
        paragraph: "para",
        literal: "literallayout",
        title: "title",
        link: "link",
        strong: "emphasis",
        emphasis: "emphasis",
        monospace: "literal"
      }.freeze
      TITLED_BLOCK_NAMES = {
        example: "example",
        quote: "blockquote",
        sidebar: "sidebar"
      }.freeze

      def convert(document)
        title = document.doctitle || "Untitled"
        body = render_nodes(document)
        %(<article>\n<title>#{escape title}</title>\n#{body}\n</article>)
      end

      private

      def section(node)
        body = render_nodes(node)
        %(<section>\n<title>#{render_text node}</title>\n#{body}\n</section>)
      end

      def listing(node)
        language = node.attributes[:language]
        attrs = language ? %( language="#{escape_attr language}") : ""
        "<programlisting#{attrs}>#{escape node.text}</programlisting>"
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
        "<#{name}>#{paragraph_content node}</#{name}>"
      end

      def titled_block(node)
        tag_name = TITLED_BLOCK_NAMES.fetch(node.context)
        title = node.attributes[:title] ? "<title>#{render_text node.attributes[:title]}</title>\n" : ""
        "<#{tag_name}>\n#{title}#{paragraph_content node}\n</#{tag_name}>"
      end

      def paragraph_content(node)
        child_nodes(node).empty? ? "<para>#{render_text node}</para>" : render_nodes(node)
      end

      def column_count(node)
        node.children.map { |row| row.children.length }.max || 1
      end

      def link_attrs(node)
        { "xlink:href": node.attributes.fetch(:target) }
      end

      def element_attrs(context)
        context == :strong ? { role: "strong" } : super
      end
    end
  end
end
