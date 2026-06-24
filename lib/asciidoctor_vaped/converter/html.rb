# frozen_string_literal: true

module AsciidoctorVaped
  module Converter
    class HTML < BaseConverter
      def convert(document)
        body = document.blocks.map { |block| convert_node(block) }.join("\n")
        return body if @options[:header_footer] == false

        [doctype, "<html>", head(document), "<body>", body, "</body>", "</html>"].join("\n")
      end

      private

      def convert_node(node)
        case node.context
        when :section then section(node)
        when :paragraph then %(<p>#{inline node.text}</p>)
        when :listing then listing(node)
        when :literal then %(<pre>#{escape node.text}</pre>)
        when :ulist then list(node, "ul")
        when :olist then list(node, "ol")
        when :table then table(node)
        when :admonition then admonition(node)
        when :example then block("exampleblock", node)
        when :quote then block("quoteblock", node)
        when :sidebar then block("sidebarblock", node)
        when :open then node.blocks.map { |block| convert_node(block) }.join("\n")
        else inline(node.text.to_s)
        end
      end

      def section(node)
        level = node.attributes.fetch(:level, 1)
        heading = "h#{[level + 1, 6].min}"
        contents = node.blocks.map { |block| convert_node(block) }.join("\n")
        %(<div class="sect#{level}">\n<#{heading}>#{inline node.text}</#{heading}>\n#{contents}\n</div>)
      end

      def listing(node)
        language = node.attributes[:language]
        code_attrs = language ? %( class="language-#{escape_attr language}" data-lang="#{escape_attr language}") : ""
        %(<div class="listingblock">\n#{title node}\n<div class="content">\n<pre class="highlight"><code#{code_attrs}>#{escape node.text}</code></pre>\n</div>\n</div>)
      end

      def list(node, tag)
        items = node.blocks.map { |item| "<li><p>#{inline item.text}</p></li>" }.join("\n")
        %(<div class="#{tag == "ul" ? "ulist" : "olist"}">\n<#{tag}>\n#{items}\n</#{tag}>\n</div>)
      end

      def table(node)
        rows = node.blocks.map { |row| table_row(row) }.join("\n")
        %(<table class="tableblock frame-all grid-all stretch">\n<tbody>\n#{rows}\n</tbody>\n</table>)
      end

      def table_row(row)
        cells = row.blocks.map { |cell| %(<td class="tableblock halign-left valign-top"><p class="tableblock">#{inline cell.text}</p></td>) }
        "<tr>\n#{cells.join("\n")}\n</tr>"
      end

      def admonition(node)
        name = node.attributes.fetch(:name, "note").to_s
        %(<div class="admonitionblock #{escape_attr name.downcase}">\n<table>\n<tr>\n<td class="icon"><div class="title">#{escape name.capitalize}</div></td>\n<td class="content">#{inline node.text}</td>\n</tr>\n</table>\n</div>)
      end

      def block(class_name, node)
        body = node.blocks.empty? ? inline(node.text.to_s) : node.blocks.map { |block| convert_node(block) }.join("\n")
        %(<div class="#{class_name}">\n#{title node}\n<div class="content">#{body}</div>\n</div>)
      end

      def title(node)
        return "" unless node.attributes[:title]

        %(<div class="title">#{inline node.attributes[:title]}</div>)
      end

      def inline(text)
        escaped = escape(text.to_s)
        links = []
        escaped = escaped.gsub(%r{https?://[^\s\[]+\[([^\]]+)\]}) do
          links << %(<a href="#{escape_attr Regexp.last_match(0).split("[").first}">#{Regexp.last_match(1)}</a>)
          "\0#{links.length - 1}\0"
        end
        escaped = escaped.gsub(/\b(https?:\/\/[^\s<]+)/, '<a href="\1">\1</a>')
        escaped = escaped.gsub(/\*([^*]+)\*/, '<strong>\1</strong>')
        escaped = escaped.gsub(/_([^_]+)_/, '<em>\1</em>')
        escaped.gsub(/`([^`]+)`/, '<code>\1</code>').gsub(/\0(\d+)\0/) { links[Regexp.last_match(1).to_i] }
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
