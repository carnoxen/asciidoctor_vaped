# frozen_string_literal: true

require_relative "ast/document"
require_relative "ast/element"
require_relative "ast/node"
require_relative "parser/blocks"
require_relative "parser/context"
require_relative "parser/inline"
require_relative "reader"

module AsciidoctorVaped
  module Parser
    NODE_HANDLERS = [
      Blocks::BlankLine,
      Blocks::DocumentAttribute,
      Blocks::Caption,
      Blocks::ElementAttributes,
      Blocks::Comment,
      Blocks::Heading,
      Blocks::Listing,
      Blocks::Literal,
      Blocks::Example,
      Blocks::Quote,
      Blocks::Sidebar,
      Blocks::Open,
      Blocks::Passthrough,
      Blocks::Table,
      Blocks::Admonition,
      Blocks::UnorderedList,
      Blocks::OrderedList,
      Blocks::Paragraph
    ].freeze
    NODE_CHAIN = Blocks.chain(NODE_HANDLERS)

    module_function

    def parse(source, attributes: {})
      document = AST::Document.new(source.to_s, attributes:)
      context = Context.new(document, Reader.new(source))
      parse_header(context)
      parse_nodes(context)
      document
    end

    def parse_header(context)
      context.reader.skip_blank_lines
      parse_header_attributes(context)
      parse_document_title(context)
    end

    def parse_nodes(context)
      until context.reader.eof?
        NODE_CHAIN.handle(context)
      end
    end

    def parse_header_attributes(context)
      handler = Blocks::DocumentAttribute.new
      handler.handle(context) while handler.match?(context)
    end

    def parse_document_title(context)
      title = context.reader.peek&.match(/\A=\s+(.+)\z/)
      return unless title

      context.document.doctitle = title[1]
      context.document.register_attribute("doctitle", title[1])
      context.reader.read
    end
  end
end
