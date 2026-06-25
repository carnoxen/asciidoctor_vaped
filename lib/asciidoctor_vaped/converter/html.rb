# frozen_string_literal: true

module AsciidoctorVaped
  module Converter
    class HTML < BaseConverter
      def convert(document)
        body = node_children(document).map { |child| convert_node(child) }.join("\n")
        return body if @options[:header_footer] == false

        [doctype, "<html>", head(document), "<body>", body, "</body>", "</html>"].join("\n")
      end

      private

      def convert_node(node)
        case node.context
        when :section then section(node)
        when :paragraph then %(<p>#{inline node}</p>)
        when :listing then listing(node)
        when :literal then %(<pre>#{escape node.text}</pre>)
        when :ulist then list(node, "ul")
        when :olist then list(node, "ol")
        when :table then table(node)
        when :admonition then admonition(node)
        when :example then block("exampleblock", node)
        when :quote then block("quoteblock", node)
        when :sidebar then block("sidebarblock", node)
        when :pass then node.text.to_s
        when :open then open(node)
        else inline(node.text.to_s)
        end
      end

      def section(node)
        level = node.attributes.fetch(:level, 1)
        heading = "h#{[level + 1, 6].min}"
        contents = node_children(node).map { |child| convert_node(child) }.join("\n")
        %(<div class="sect#{level}">\n<#{heading}>#{inline node}</#{heading}>\n#{contents}\n</div>)
      end

      def listing(node)
        language = node.attributes[:language]
        code_attrs = language ? %( class="language-#{escape_attr language}" data-lang="#{escape_attr language}") : ""
        %(<div class="listingblock">\n#{title node}\n<div class="content">\n<pre class="highlight"><code#{code_attrs}>#{escape node.text}</code></pre>\n</div>\n</div>)
      end

      def list(node, tag)
        items = node.children.map { |item| "<li>#{inline item}</li>" }.join("\n")
        %(<div class="#{tag == "ul" ? "ulist" : "olist"}">\n<#{tag}>\n#{items}\n</#{tag}>\n</div>)
      end

      def table(node)
        rows = node.children.map { |row| table_row(row) }.join("\n")
        %(<table class="tableblock frame-all grid-all stretch">\n<tbody>\n#{rows}\n</tbody>\n</table>)
      end

      def table_row(row)
        cells = row.children.map { |cell| %(<td class="tableblock halign-left valign-top">#{inline cell}</td>) }
        "<tr>\n#{cells.join("\n")}\n</tr>"
      end

      def admonition(node)
        name = node.attributes.fetch(:name, "note").to_s
        %(<div class="admonitionblock #{escape_attr name.downcase}">\n<table>\n<tr>\n<td class="icon"><div class="title">#{escape name.capitalize}</div></td>\n<td class="content">#{inline node}</td>\n</tr>\n</table>\n</div>)
      end

      def block(class_name, node)
        children = node_children(node)
        body = children.empty? ? inline(node) : children.map { |child| convert_node(child) }.join("\n")
        %(<div class="#{class_name}">\n#{title node}\n<div class="content">#{body}</div>\n</div>)
      end

      def open(node)
        children = node_children(node)
        return inline(node) if children.empty?

        children.map { |child| convert_node(child) }.join("\n")
      end

      def title(node)
        return "" unless node.attributes[:title]

        %(<div class="title">#{inline node.attributes[:title]}</div>)
      end

      def inline(value)
        nodes = value.respond_to?(:children) ? inline_nodes(value) : Parser::Inline.parse(value)
        return escape(value.text.to_s) if nodes.empty? && value.respond_to?(:text)

        nodes.map { |node| inline_node(node) }.join
      end

      def inline_node(node)
        case node.context
        when :text then escape(node.text)
        when :link then %(<a href="#{escape_attr node.attributes.fetch(:target)}">#{inline node}</a>)
        when :strong then "<strong>#{inline node}</strong>"
        when :emphasis then "<em>#{inline node}</em>"
        when :monospace then "<code>#{escape node.text}</code>"
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

      def doctype
        "<!DOCTYPE html>"
      end

      def head(document)
        title = document.doctitle || "Untitled"
        "<head><meta charset=\"utf-8\"><title>#{escape title}</title></head>"
      end
    end
  end
end
