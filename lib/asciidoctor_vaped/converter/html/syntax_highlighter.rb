# frozen_string_literal: true

require_relative "../../parser/inlines/callouts"

module AsciidoctorVaped
  module SyntaxHighlighter
    class Error < LoadError; end

    module_function

    def create(document)
      name = document.attributes["syntax-highlighter"] || document.attributes[:"syntax-highlighter"] || "highlightjs"
      case name.to_s.downcase
      when "highlightjs", "highlight.js" then HighlightJS.new(document)
      when "rouge", "rough" then Rouge.new(document)
      when "pygments" then Pygments.new(document)
      else raise ArgumentError, "unknown syntax highlighter: #{name}"
      end
    end

    class Base
      attr_reader :document

      def initialize(document)
        @document = document
      end

      def head = ""
      def footer = ""

      def highlight(source, language, marks, &marker)
        Callouts.restore_html(highlight_source(source, language), marks, &marker)
      end

      private

      def attribute(name, default = nil)
        document.attributes.fetch(name, document.attributes.fetch(name.to_sym, default))
      end

      def escape(value)
        value.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub('"', "&quot;")
      end
    end

    class HighlightJS < Base
      VERSION = "11.11.1"
      SCRIPT = File.read(File.expand_path("../../assets/html/highlightjs.js", __dir__)).freeze

      def head
        %(<link rel="stylesheet" href="#{base_url}/styles/#{attribute "highlightjs-theme", "github"}.min.css">)
      end

      def footer
        %(<script src="#{base_url}/highlight.min.js"></script>\n<script>\n#{SCRIPT}</script>)
      end

      private

      def highlight_source(source, _language) = escape(source)

      def base_url
        attribute "highlightjsdir", "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/#{VERSION}"
      end
    end

    class Rouge < Base
      private

      def highlight_source(source, language)
        require "rouge"
        lexer = ::Rouge::Lexer.find_fancy(language, source) || ::Rouge::Lexers::PlainText
        theme = ::Rouge::Theme.find(attribute("rouge-style", "github")) || ::Rouge::Themes::Github
        ::Rouge::Formatters::HTMLInline.new(theme.new).format(lexer.lex(source))
      rescue LoadError
        raise Error, "Rouge highlighting requires the optional 'rouge' gem"
      end
    end

    class Pygments < Base
      private

      def highlight_source(source, language)
        require "pygments"
        options = { nowrap: true, noclasses: true }
        lexer = ::Pygments.lexers.values.any? { |details| details[:aliases].include?(language) } ? language : "text"
        ::Pygments.highlight(source, lexer:, options:) || escape(source)
      rescue LoadError
        raise Error, "Pygments highlighting requires the optional 'pygments.rb' gem"
      end
    end
  end
end
