# frozen_string_literal: true

module AsciidoctorVaped
  module Converter
    class DocBook
      def initialize(_options = {})
      end

      def convert(document)
        title = document.doctitle || "Untitled"
        body = document.blocks.map { |block| convert_node(block) }.join("\n")
        %(<article>\n<title>#{escape title}</title>\n#{body}\n</article>)
      end

      private

      def convert_node(node)
        case node.context
        when :section then section(node)
        when :paragraph then "<para>#{inline node.text}</para>"
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
        body = node.blocks.map { |block| convert_node(block) }.join("\n")
        %(<section>\n<title>#{inline node.text}</title>\n#{body}\n</section>)
      end

      def listing(node)
        language = node.attributes[:language]
        attrs = language ? %( language="#{escape_attr language}") : ""
        "<programlisting#{attrs}>#{escape node.text}</programlisting>"
      end

      def list(node, tag)
        items = node.blocks.map { |item| "<listitem><para>#{inline item.text}</para></listitem>" }.join("\n")
        "<#{tag}>\n#{items}\n</#{tag}>"
      end

      def table(node)
        rows = node.blocks.map do |row|
          cells = row.blocks.map { |cell| "<entry>#{inline cell.text}</entry>" }.join
          "<row>#{cells}</row>"
        end.join("\n")
        "<informaltable>\n<tgroup cols=\"#{column_count node}\">\n<tbody>\n#{rows}\n</tbody>\n</tgroup>\n</informaltable>"
      end

      def admonition(node)
        name = node.attributes.fetch(:name, "note").to_s.downcase
        "<#{name}><para>#{inline node.text}</para></#{name}>"
      end

      def titled_block(tag, node)
        title = node.attributes[:title] ? "<title>#{inline node.attributes[:title]}</title>\n" : ""
        "<#{tag}>\n#{title}<para>#{inline node.text}</para>\n</#{tag}>"
      end

      def column_count(node)
        node.blocks.map { |row| row.blocks.length }.max || 1
      end

      def inline(text)
        escape(text.to_s)
          .gsub(%r{https?://[^\s\[]+\[([^\]]+)\]}) { %(<link xlink:href="#{escape_attr Regexp.last_match(0).split("[").first}">#{Regexp.last_match(1)}</link>) }
          .gsub(/\*([^*]+)\*/, '<emphasis role="strong">\1</emphasis>')
          .gsub(/_([^_]+)_/, '<emphasis>\1</emphasis>')
          .gsub(/`([^`]+)`/, '<literal>\1</literal>')
      end

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
    end
  end
end
