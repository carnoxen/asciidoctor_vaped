# frozen_string_literal: true

module AsciidoctorVaped
  module Converter
    class HTML < BaseConverter
      ELEMENT_NAMES = {
        section: "section",
        paragraph: "p",
        literal: "pre",
        block_title: "h2",
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
        pass: "passblock",
        image: "imageblock",
        audio: "audioblock",
        video: "videoblock"
      }.freeze

      def convert(document)
        @document = document
        body = render_nodes(document)
        return body if @options[:header_footer] == false

        body = [document_title(document), body].reject(&:empty?).join("\n")
        head = tag("head", "\n    #{tag "meta", nil, charset: "utf-8"}\n  ")
        body = tag("body", "\n    #{body}\n  ")
        "#{tag "!DOCTYPE html"}\n#{tag "html", "\n  #{head}\n  #{body}\n"}"
      end

      def section(node)
        level = node.attributes.fetch(:level, 1)
        heading = "h#{[level + 1, 6].min}"
        content = "\n#{tag heading, render_text(node)}\n#{render_nodes node}\n"
        tag(element_name(:section), content)
      end

      def listing(node)
        language = node.attributes[:language]
        attrs = language ? { class: "language-#{language}", "data-lang": language } : {}
        figure(node, tag("pre", tag("code", escape(node.text), attrs), class: "highlight"))
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
        heading = node.attributes[:title] ? "#{tag "h2", render_text(node.attributes[:title])}\n" : ""
        tag("aside", "\n#{heading}#{render_content node}\n")
      end

      def media(node)
        content = send("#{node.context}_media", node)
        content = tag("a", content, href: node.attributes[:link]) if node.attributes[:link]
        figure(node, content)
      end

      def image_media(node)
        attrs = media_dimensions(node).merge(
          src: media_target(node),
          alt: node.attributes.fetch(:alt, default_alt(node))
        )
        tag("img", nil, attrs)
      end

      def audio_media(node)
        attrs = media_options(node).merge(src: node.attributes.fetch(:target))
        tag("audio", "", attrs)
      end

      def video_media(node)
        return embedded_video(node) if node.attributes[:provider]

        attrs = media_options(node).merge(media_dimensions(node)).merge(
          src: timed_media_target(node),
          poster: node.attributes[:poster]
        )
        tag("video", "", attrs)
      end

      def list(node)
        return description_list(node) if node.context == :dlist

        tag_name = list_tag(node)
        items = node.children.map { |item| list_item(item) }.join("\n")
        tag(tag_name, "\n#{items}\n")
      end

      def list_item(node)
        nested = render_nodes(node)
        nested = "\n#{nested}" unless nested.empty?
        tag("li", "#{render_text node}#{nested}")
      end

      def description_list(node)
        items = node.children.map { |item| description_item(item) }.join("\n")
        tag("dl", "\n#{items}\n")
      end

      def description_item(node)
        term = node.children.find { |child| child.context == :term }
        description = node.children.find { |child| child.context == :description }
        nested = node.children.reject { |child| child.equal?(term) || child.equal?(description) }
          .map { |child| convert_node(child) }.join("\n")
        nested = "\n#{nested}" unless nested.empty?
        "#{tag "dt", render_text(term)}\n#{tag "dd", "#{render_text description}#{nested}"}"
      end

      def table(node)
        rows = node.children.dup
        head = "#{tag "thead", "\n#{table_row rows.shift, "th"}\n"}\n" if node.attributes[:header] && rows.any?
        body = rows.map { |row| table_row(row, "td") }.join("\n")
        content = "\n#{head}#{tag "tbody", "\n#{body}\n"}\n"
        tag("table", content, class: "tableblock frame-all grid-all stretch")
      end

      def table_row(row, tag_name = "td")
        cells = row.children.map do |cell|
          tag(tag_name, render_text(cell), class: "tableblock halign-left valign-top")
        end
        tag("tr", "\n#{cells.join("\n")}\n")
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
        context == :block_title ? { class: "title" } : super
      end

      def link_attrs(node)
        { href: node.attributes.fetch(:target) }
      end

      def article(node, class_name)
        tag("article", "\n#{block_title node}\n#{render_content node}\n", class: class_name)
      end

      def figure(node, content)
        class_name = DELIMITED_BLOCK_CLASSES.fetch(node.context)
        tag("figure", "\n#{figcaption node}\n#{content}\n", class: class_name)
      end

      def media_dimensions(node)
        { width: node.attributes[:width], height: node.attributes[:height] }
      end

      def media_options(node)
        %i[autoplay controls loop muted].each_with_object({ controls: true }) do |option, attrs|
          attrs[option] = true if node.attributes[option]
        end
      end

      def embedded_video(node)
        provider = node.attributes.fetch(:provider)
        source = video_provider_url(provider, embed: true)
        attrs = media_dimensions(node).merge(src: "#{source}#{node.attributes.fetch(:target)}", allowfullscreen: true)
        tag("iframe", "", attrs)
      end

      def timed_media_target(node)
        start_at = node.attributes[:start]
        end_at = node.attributes[:end]
        return node.attributes.fetch(:target) unless start_at || end_at

        "#{node.attributes.fetch(:target)}#t=#{start_at || 0}#{",#{end_at}" if end_at}"
      end

      def default_alt(node)
        File.basename(node.attributes.fetch(:target), ".*").tr("_-", " ")
      end

      def figcaption(node)
        return "" unless node.attributes[:title]

        tag("figcaption", render_text(node.attributes[:title]), class: "title")
      end

      def list_tag(node)
        node.context == :olist ? "ol" : "ul"
      end

      def document_title(document)
        return "" unless document.doctitle

        title, subtitle = partition_title(document)
        subtitle = "\n#{tag "p", render_text(subtitle)}" if subtitle
        tag("hgroup", "\n#{tag "h1", render_text(title)}#{subtitle}\n")
      end

      def partition_title(document)
        separator = "#{document.attributes.fetch("title-separator", ":")} "
        title, match, subtitle = document.doctitle.rpartition(separator)
        match.empty? ? [document.doctitle, nil] : [title, subtitle]
      end
    end
  end
end
