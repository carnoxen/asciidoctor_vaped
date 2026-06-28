# frozen_string_literal: true

require_relative "../parser/inline"

module AsciidoctorVaped
  module Converter
    class BaseConverter
      NODE_RENDERERS = {
        section: :section,
        paragraph: :paragraph,
        listing: :listing,
        literal: :literal,
        ulist: :list,
        olist: :list,
        dlist: :list,
        table: :table,
        admonition: :admonition,
        example: :titled_block,
        quote: :titled_block,
        sidebar: :sidebar,
        pass: :pass,
        open: :open,
        image: :media,
        audio: :media,
        video: :media,
        link: :link,
        strong: :inline,
        emphasis: :inline,
        monospace: :inline
      }.freeze
      TEXT_NODE_CONTEXTS = %i[link strong emphasis monospace].freeze

      def initialize(options = {})
        @options = options
      end

      def convert(_document)
        raise NotImplementedError, "#{self.class} must implement #convert"
      end

      private

      def convert_node(node)
        return escape(node) if node.is_a?(String)

        send(NODE_RENDERERS.fetch(node.context, :fallback), node)
      end

      def paragraph(node)
        tag(element_name(:paragraph), render_text(node))
      end

      def literal(node)
        tag(element_name(:literal), escape(node.text))
      end

      def pass(node)
        node.text.to_s
      end

      def open(node)
        render_content(node)
      end

      def sidebar(node)
        titled_block(node)
      end

      def link(node)
        tag(element_name(:link), render_text(node), link_attrs(node))
      end

      def media_target(node)
        target = node.attributes.fetch(:target)
        provider = node.attributes[:provider]
        return "#{video_provider_url provider}#{target}" if provider
        return target unless node.context == :image

        imagesdir = @document.attributes["imagesdir"] || @document.attributes[:imagesdir]
        return target if !imagesdir || imagesdir.empty? || target.match?(/\A(?:[a-z][a-z0-9+.-]*:|\/)/i)

        "#{imagesdir.sub(%r{/\z}, "")}/#{target}"
      end

      def video_provider_url(provider, embed: false)
        case provider
        when "youtube" then embed ? "https://www.youtube.com/embed/" : "https://www.youtube.com/watch?v="
        when "vimeo" then embed ? "https://player.vimeo.com/video/" : "https://vimeo.com/"
        end
      end

      def inline(node)
        content = node.context == :monospace ? escape(node.text) : render_text(node)
        tag(element_name(node.context), content, element_attrs(node.context))
      end

      def fallback(node)
        render_text(node.text.to_s)
      end

      def title(node)
        return "" unless node.attributes[:title]

        tag(element_name(:title), render_text(node.attributes[:title]), element_attrs(:title))
      end

      def element_name(name)
        self.class::ELEMENT_NAMES.fetch(name)
      end

      def element_attrs(_context)
        {}
      end

      def escape(value)
        value.to_s
          .gsub("&", "&amp;")
          .gsub("<", "&lt;")
          .gsub(">", "&gt;")
          .gsub('"', "&quot;")
      end

      def escape_attr(value)
        escape(value)
      end

      def tag(name, content = nil, attrs = {})
        opening = "<#{name}#{html_attrs attrs}>"
        content.nil? ? opening : "#{opening}#{content}</#{name}>"
      end

      def html_attrs(attrs)
        attrs.compact.map { |key, value| %( #{key}="#{escape_attr value}") }.join
      end

      def render_nodes(node)
        child_nodes(node).map { |child| convert_node(child) }.join("\n")
      end

      def render_content(node)
        child_nodes(node).empty? ? render_text(node) : render_nodes(node)
      end

      def render_text(value)
        nodes = value.respond_to?(:children) ? text_children(value) : Parser::Inline.parse(value)
        return escape(value.text.to_s) if nodes.empty? && value.respond_to?(:text)

        nodes.map { |node| convert_node(node) }.join
      end

      def child_nodes(node)
        node.children.reject { |child| text_node?(child) }
      end

      def text_children(node)
        node.children.select { |child| text_node?(child) }
      end

      def text_node?(node)
        node.is_a?(String) || TEXT_NODE_CONTEXTS.include?(node.context)
      end
    end
  end
end
