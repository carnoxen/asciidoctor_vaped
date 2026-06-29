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

      def head
        %(<link rel="stylesheet" href="#{base_url}/styles/#{attribute "highlightjs-theme", "github"}.min.css">)
      end

      def footer
        <<~HTML.chomp
          <script src="#{base_url}/highlight.min.js"></script>
          <script>
          document.querySelectorAll('pre.highlight > code[data-lang]').forEach((code) => {
            const callouts = [...code.querySelectorAll('.conum')].map((mark, index) => {
              const range = document.createRange()
              range.setStart(code, 0)
              range.setEndBefore(mark)
              const callout = { position: range.toString().length, value: mark.dataset.value, index }
              const label = mark.nextElementSibling
              mark.remove()
              if (label?.tagName === 'B') label.remove()
              return callout
            })
            hljs.highlightElement(code)
            callouts.sort((left, right) => right.position - left.position || right.index - left.index).forEach((callout) => {
              const walker = document.createTreeWalker(code, NodeFilter.SHOW_TEXT)
              let node, position = 0
              while ((node = walker.nextNode())) {
                if (callout.position <= position + node.length) {
                  const tail = node.splitText(callout.position - position)
                  const mark = Object.assign(document.createElement('i'), { className: 'conum' })
                  mark.dataset.value = callout.value
                  tail.before(mark, Object.assign(document.createElement('b'), { textContent: `(${callout.value})` }))
                  break
                }
                position += node.length
              }
            })
          })
          </script>
        HTML
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
        ::Pygments.highlight(source, lexer: language || "text", options:) || escape(source)
      rescue LoadError
        raise Error, "Pygments highlighting requires the optional 'pygments.rb' gem"
      end
    end
  end
end
