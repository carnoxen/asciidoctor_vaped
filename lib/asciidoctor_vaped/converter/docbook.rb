# frozen_string_literal: true

module AsciidoctorVaped
  module Converter
    class DocBook < BaseConverter
      def convert(document)
        title = document.doctitle || "Untitled"
        body = node_children(document).map { |child| convert_node(child) }.join("\n")
        %(<article>\n<title>#{escape title}</title>\n#{body}\n</article>)
      end

      private

      def convert_node(node)
        case node.context
        when :section then section(node)
        when :paragraph then "<para>#{inline node}</para>"
        when :listing then listing(node)
        when :literal then "<literallayout>#{escape node.text}</literallayout>"
        when :ulist then list(node, "itemizedlist")
        when :olist then list(node, "orderedlist")
        when :table then table(node)
        when :admonition then admonition(node)
        when :example then titled_block("example", node)
        when :quote then titled_block("blockquote", node)
        when :sidebar then titled_block("sidebar", node)
        else inline(node.text.to_s)
        end
      end

      def section(node)
        body = node_children(node).map { |child| convert_node(child) }.join("\n")
        %(<section>\n<title>#{inline node}</title>\n#{body}\n</section>)
      end

      def listing(node)
        language = node.attributes[:language]
        attrs = language ? %( language="#{escape_attr language}") : ""
        "<programlisting#{attrs}>#{escape node.text}</programlisting>"
      end

      def list(node, tag)
        items = node.children.map { |item| "<listitem><para>#{inline item}</para></listitem>" }.join("\n")
        "<#{tag}>\n#{items}\n</#{tag}>"
      end

      def table(node)
        rows = node.children.map do |row|
          cells = row.children.map { |cell| "<entry>#{inline cell}</entry>" }.join
          "<row>#{cells}</row>"
        end.join("\n")
        "<informaltable>\n<tgroup cols=\"#{column_count node}\">\n<tbody>\n#{rows}\n</tbody>\n</tgroup>\n</informaltable>"
      end

      def admonition(node)
        name = node.attributes.fetch(:name, "note").to_s.downcase
        "<#{name}><para>#{inline node}</para></#{name}>"
      end

      def titled_block(tag, node)
        title = node.attributes[:title] ? "<title>#{inline node.attributes[:title]}</title>\n" : ""
        "<#{tag}>\n#{title}<para>#{inline node}</para>\n</#{tag}>"
      end

      def column_count(node)
        node.children.map { |row| row.children.length }.max || 1
      end

      def inline(value)
        nodes = value.respond_to?(:children) ? inline_nodes(value) : Parser::Inline.parse(value)
        return escape(value.text.to_s) if nodes.empty? && value.respond_to?(:text)

        nodes.map { |node| inline_node(node) }.join
      end

      def inline_node(node)
        case node.context
        when :text then escape(node.text)
        when :link then %(<link xlink:href="#{escape_attr node.attributes.fetch(:target)}">#{inline node}</link>)
        when :strong then %(<emphasis role="strong">#{inline node}</emphasis>)
        when :emphasis then "<emphasis>#{inline node}</emphasis>"
        when :monospace then "<literal>#{escape node.text}</literal>"
        else inline(node.text.to_s)
        end
      end

      def node_children(node)
        node.children.reject { |child| inline_context?(child.context) }
      end

      def inline_nodes(node)
        node.children.select { |child| inline_context?(child.context) }
      end

      def inline_context?(context)
        %i[text link strong emphasis monospace].include?(context)
      end
    end
  end
end
