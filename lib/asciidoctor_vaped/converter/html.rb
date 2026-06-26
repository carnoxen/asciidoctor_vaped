# frozen_string_literal: true

module AsciidoctorVaped
  module Converter
    class HTML < BaseConverter
      include Converter::Node

      def convert(document)
        title = document.doctitle || "Untitled"
        body = render_nodes(document)
        return body if @options[:header_footer] == false

%(<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>#{escape title}</title>
  </head>
  <body>
    #{body}
  </body>
</html>)
      end

      def paragraph_tag
        "p"
      end

      def section(node)
        level = node.attributes.fetch(:level, 1)
        heading = "h#{[level + 1, 6].min}"
        %(<div class="sect#{level}">\n<#{heading}>#{render_text node}</#{heading}>\n#{render_nodes node}\n</div>)
      end

      def listing(node)
        language = node.attributes[:language]
        code_attrs = language ? %( class="language-#{escape_attr language}" data-lang="#{escape_attr language}") : ""
        %(<div class="listingblock">\n#{title node}\n<div class="content">\n<pre class="highlight"><code#{code_attrs}>#{escape node.text}</code></pre>\n</div>\n</div>)
      end

      def literal_tag
        "pre"
      end

      def list(node)
        tag_name = list_tag(node)
        items = node.children.map { |item| list_item(item) }.join("\n")
        %(<div class="#{node.context}">\n<#{tag_name}>\n#{items}\n</#{tag_name}>\n</div>)
      end

      def list_item(node)
        "<li>#{render_content node}</li>"
      end

      def table(node)
        rows = node.children.map { |row| table_row(row) }.join("\n")
        %(<table class="tableblock frame-all grid-all stretch">\n<tbody>\n#{rows}\n</tbody>\n</table>)
      end

      def table_row(row)
        cells = row.children.map { |cell| %(<td class="tableblock halign-left valign-top">#{render_text cell}</td>) }
        "<tr>\n#{cells.join("\n")}\n</tr>"
      end

      def admonition(node)
        name = node.attributes.fetch(:name, "note").to_s
        %(<div class="admonitionblock #{escape_attr name.downcase}">\n<table>\n<tr>\n<td class="icon"><div class="title">#{escape name.capitalize}</div></td>\n<td class="content">#{render_content node}</td>\n</tr>\n</table>\n</div>)
      end

      def example(node)
        wrapped_node("exampleblock", node)
      end

      def quote(node)
        wrapped_node("quoteblock", node)
      end

      def sidebar(node)
        wrapped_node("sidebarblock", node)
      end

      def title_tag
        "div"
      end

      def title_attrs
        { class: "title" }
      end

      def link_tag
        "a"
      end

      def link_attrs(node)
        { href: node.attributes.fetch(:target) }
      end

      def strong_tag
        "strong"
      end

      def emphasis_tag
        "em"
      end

      def monospace_tag
        "code"
      end

      def wrapped_node(class_name, node)
        %(<div class="#{class_name}">\n#{title node}\n<div class="content">#{render_content node}</div>\n</div>)
      end

      def list_tag(node)
        node.context == :olist ? "ol" : "ul"
      end
    end
  end
end
