# frozen_string_literal: true

module AsciidoctorVaped
  module Converter
    class HTML < BaseConverter
      BLOCK_RENDERERS = {
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
        open: :open
      }.freeze

      INLINE_CONTEXTS = %i[text link strong emphasis monospace].freeze

      def convert(document)
        body = render_blocks(document)
        return body if @options[:header_footer] == false

        [doctype, "<html>", head(document), "<body>", body, "</body>", "</html>"].join("\n")
      end

      private

      def convert_node(node)
        send(BLOCK_RENDERERS.fetch(node.context, :fallback), node)
      end

      def render_blocks(node)
        block_children(node).map { |child| convert_node(child) }.join("\n")
      end

      def render_body(node)
        block_children(node).empty? ? render_inline(node) : render_blocks(node)
      end

      def paragraph(node)
        %(<p>#{render_inline node}</p>)
      end

      def section(node)
        level = node.attributes.fetch(:level, 1)
        heading = "h#{[level + 1, 6].min}"
        %(<div class="sect#{level}">\n<#{heading}>#{render_inline node}</#{heading}>\n#{render_blocks node}\n</div>)
      end

      def listing(node)
        language = node.attributes[:language]
        code_attrs = language ? %( class="language-#{escape_attr language}" data-lang="#{escape_attr language}") : ""
        %(<div class="listingblock">\n#{title node}\n<div class="content">\n<pre class="highlight"><code#{code_attrs}>#{escape node.text}</code></pre>\n</div>\n</div>)
      end

      def literal(node)
        %(<pre>#{escape node.text}</pre>)
      end

      def list(node)
        tag = list_tag(node)
        items = node.children.map { |item| list_item(item) }.join("\n")
        %(<div class="#{node.context}">\n<#{tag}>\n#{items}\n</#{tag}>\n</div>)
      end

      def list_item(node)
        "<li>#{render_body node}</li>"
      end

      def table(node)
        rows = node.children.map { |row| table_row(row) }.join("\n")
        %(<table class="tableblock frame-all grid-all stretch">\n<tbody>\n#{rows}\n</tbody>\n</table>)
      end

      def table_row(row)
        cells = row.children.map { |cell| %(<td class="tableblock halign-left valign-top">#{render_inline cell}</td>) }
        "<tr>\n#{cells.join("\n")}\n</tr>"
      end

      def admonition(node)
        name = node.attributes.fetch(:name, "note").to_s
        %(<div class="admonitionblock #{escape_attr name.downcase}">\n<table>\n<tr>\n<td class="icon"><div class="title">#{escape name.capitalize}</div></td>\n<td class="content">#{render_body node}</td>\n</tr>\n</table>\n</div>)
      end

      def example(node)
        wrapped_block("exampleblock", node)
      end

      def quote(node)
        wrapped_block("quoteblock", node)
      end

      def sidebar(node)
        wrapped_block("sidebarblock", node)
      end

      def wrapped_block(class_name, node)
        %(<div class="#{class_name}">\n#{title node}\n<div class="content">#{render_body node}</div>\n</div>)
      end

      def pass(node)
        node.text.to_s
      end

      def open(node)
        render_body(node)
      end

      def fallback(node)
        render_inline(node.text.to_s)
      end

      def title(node)
        return "" unless node.attributes[:title]

        %(<div class="title">#{render_inline node.attributes[:title]}</div>)
      end

      def render_inline(value)
        nodes = value.respond_to?(:children) ? inline_children(value) : Parser::Inline.parse(value)
        return escape(value.text.to_s) if nodes.empty? && value.respond_to?(:text)

        nodes.map { |node| inline_node(node) }.join
      end

      def inline_node(node)
        case node.context
        when :text then escape(node.text)
        when :link then %(<a href="#{escape_attr node.attributes.fetch(:target)}">#{render_inline node}</a>)
        when :strong then "<strong>#{render_inline node}</strong>"
        when :emphasis then "<em>#{render_inline node}</em>"
        when :monospace then "<code>#{escape node.text}</code>"
        else render_inline(node.text.to_s)
        end
      end

      def block_children(node)
        node.children.reject { |child| inline_context?(child) }
      end

      def inline_children(node)
        node.children.select { |child| inline_context?(child) }
      end

      def inline_context?(node)
        INLINE_CONTEXTS.include?(node.context)
      end

      def list_tag(node)
        node.context == :olist ? "ol" : "ul"
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
