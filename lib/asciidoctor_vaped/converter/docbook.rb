# frozen_string_literal: true

module AsciidoctorVaped
  module Converter
    class DocBook < BaseConverter
      ELEMENT_NAMES = {
        paragraph: "para",
        literal: "literallayout",
        block_title: "title",
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
        @document = document
        @listing_number = 0
        title = document.doctitle || "Untitled"
        body = render_nodes(document)
        tag("article", "\n#{tag "title", escape(title)}\n#{body}\n")
      end

      private

      def section(node)
        body = render_nodes(node)
        tag("section", "\n#{tag "title", render_text(node)}\n#{body}\n")
      end

      def listing(node)
        language = node.attributes[:language]
        attrs = language ? { language: } : {}
        extraction = Callouts.extract(node.text)
        @listing_number += 1
        @callout_ids = extraction.marks.each_with_index.each_with_object(Hash.new { |ids, number| ids[number] = [] }) do |(mark, index), ids|
          ids[mark.number] << "CO#{@listing_number}-#{index + 1}"
        end
        occurrence = Hash.new(0)
        content = Callouts.restore_html(escape(extraction.source), extraction.marks) do |mark|
          id = @callout_ids.fetch(mark.number).fetch(occurrence[mark.number])
          occurrence[mark.number] += 1
          tag("co", "", "xml:id": id)
        end
        tag("programlisting", content, attrs)
      end

      def callout_list(node)
        items = node.children.map do |item|
          ids = @callout_ids&.fetch(item.attributes[:number], nil)
          attrs = { arearefs: ids&.join(" ") }.compact
          tag("callout", tag("para", render_text(item)), attrs)
        end.join("\n")
        @callout_ids = nil
        tag("calloutlist", "\n#{items}\n")
      end

      def media(node)
        object = "#{node.context}object"
        data = "#{node.context}data"
        attrs = { fileref: media_target(node), width: node.attributes[:width] }
        attrs[:depth] = node.attributes[:height]
        content = tag(object, tag(data, "", attrs))
        if node.context == :image && node.attributes[:alt]
          content += tag("textobject", tag("phrase", escape(node.attributes[:alt])))
        end
        content += tag("caption", tag("para", render_text(node.attributes[:title]))) if node.attributes[:title]
        tag("mediaobject", content)
      end

      def list(node)
        return description_list(node) if node.context == :dlist

        tag_name = node.context == :olist ? "orderedlist" : "itemizedlist"
        items = node.children.map { |item| list_item(item) }.join("\n")
        tag(tag_name, "\n#{items}\n")
      end

      def list_item(node)
        nested = render_nodes(node)
        nested = "\n#{nested}" unless nested.empty?
        tag("listitem", "#{tag "para", render_text(node)}#{nested}")
      end

      def description_list(node)
        items = node.children.map { |item| description_item(item) }.join("\n")
        tag("variablelist", "\n#{items}\n")
      end

      def description_item(node)
        term = node.children.find { |child| child.context == :term }
        description = node.children.find { |child| child.context == :description }
        nested = node.children.reject { |child| child.equal?(term) || child.equal?(description) }
          .map { |child| convert_node(child) }.join("\n")
        nested = "\n#{nested}" unless nested.empty?
        item = tag("listitem", "#{tag "para", render_text(description)}#{nested}")
        tag("varlistentry", "#{tag "term", render_text(term)}#{item}")
      end

      def table(node)
        rows = node.children.dup
        head = "#{tag "thead", "\n#{table_row rows.shift}\n"}\n" if node.attributes[:header] && rows.any?
        body = rows.map { |row| table_row(row) }.join("\n")
        group = tag("tgroup", "\n#{head}#{tag "tbody", "\n#{body}\n"}\n", cols: column_count(node))
        tag("informaltable", "\n#{group}\n")
      end

      def admonition(node)
        name = node.attributes.fetch(:name, "note").to_s.downcase
        tag(name, paragraph_content(node))
      end

      def titled_block(node)
        tag_name = TITLED_BLOCK_NAMES.fetch(node.context)
        title = node.attributes[:title] ? "#{tag "title", render_text(node.attributes[:title])}\n" : ""
        tag(tag_name, "\n#{title}#{paragraph_content node}\n")
      end

      def paragraph_content(node)
        child_nodes(node).empty? ? tag("para", render_text(node)) : render_nodes(node)
      end

      def column_count(node)
        node.children.map { |row| row.children.length }.max || 1
      end

      def table_row(row)
        cells = row.children.map { |cell| tag("entry", render_text(cell)) }.join
        tag("row", cells)
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
