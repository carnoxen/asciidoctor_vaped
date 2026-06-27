# frozen_string_literal: true

module AsciidoctorVaped
  module Converter
    class HTML < BaseConverter
      ELEMENT_NAMES = {
        section: "section",
        paragraph: "p",
        literal: "pre",
        title: "div",
        link: "a",
        strong: "strong",
        emphasis: "em",
        monospace: "code"
      }.freeze
      DELIMITED_BLOCK_CLASSES = {
        listing: "listingblock",
        literal: "literalblock",
        example: "exampleblock",
        quote: "quoteblock",
        sidebar: "sidebarblock",
        open: "openblock",
        pass: "passblock"
      }.freeze

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

      def section(node)
        level = node.attributes.fetch(:level, 1)
        heading = "h#{[level + 1, 6].min}"
        tag_name = element_name(:section)
        %(<#{tag_name}>\n<#{heading}>#{render_text node}</#{heading}>\n#{render_nodes node}\n</#{tag_name}>)
      end

      def listing(node)
        language = node.attributes[:language]
        samp_attrs = language ? %( class="language-#{escape_attr language}" data-lang="#{escape_attr language}") : ""
        figure(node, %(<pre class="highlight"><samp#{samp_attrs}>#{escape node.text}</samp></pre>))
      end

      def literal(node)
        figure(node, tag(element_name(:literal), escape(node.text)))
      end

      def pass(node)
        figure(node, node.text.to_s)
      end

      def open(node)
        figure(node, render_content(node))
      end

      def sidebar(node)
        heading = node.attributes[:title] ? "<h2>#{render_text node.attributes[:title]}</h2>\n" : ""
        %(<aside>\n#{heading}#{render_content node}\n</aside>)
      end

      def list(node)
        tag_name = list_tag(node)
        items = node.children.map { |item| list_item(item) }.join("\n")
        %(<#{tag_name}>\n#{items}\n</#{tag_name}>)
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
        name = node.attributes.fetch(:name, "note").to_s.downcase
        article(node, "admonitionblock #{escape_attr name}")
      end

      def titled_block(node)
        content = render_content(node)
        content = tag("blockquote", content) if node.context == :quote
        figure(node, content)
      end

      def element_attrs(context)
        context == :title ? { class: "title" } : super
      end

      def link_attrs(node)
        { href: node.attributes.fetch(:target) }
      end

      def article(node, class_name)
        %(<article class="#{class_name}">\n#{title node}\n#{render_content node}\n</article>)
      end

      def figure(node, content)
        class_name = DELIMITED_BLOCK_CLASSES.fetch(node.context)
        %(<figure class="#{class_name}">\n#{figcaption node}\n#{content}\n</figure>)
      end

      def figcaption(node)
        return "" unless node.attributes[:title]

        tag("figcaption", render_text(node.attributes[:title]), class: "title")
      end

      def list_tag(node)
        node.context == :olist ? "ol" : "ul"
      end
    end
  end
end
