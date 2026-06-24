# frozen_string_literal: true

require_relative "ast/document"
require_relative "ast/node"
require_relative "parser/block_handlers"
require_relative "parser/context"
require_relative "reader"

module AsciidoctorVaped
  module Parser
    BLOCK_HANDLERS = [
      BlockHandlers::BlankLine,
      BlockHandlers::AttributeEntry,
      BlockHandlers::BlockTitle,
      BlockHandlers::AttributeList,
      BlockHandlers::Comment,
      BlockHandlers::Section,
      BlockHandlers::Listing,
      BlockHandlers::Literal,
      BlockHandlers::Example,
      BlockHandlers::Quote,
      BlockHandlers::Sidebar,
      BlockHandlers::Table,
      BlockHandlers::Admonition,
      BlockHandlers::UnorderedList,
      BlockHandlers::OrderedList,
      BlockHandlers::Paragraph
    ].freeze
    BLOCK_CHAIN = BlockHandlers.chain(BLOCK_HANDLERS)

    module_function

    def parse(source, attributes: {})
      document = AST::Document.new(source.to_s, attributes:)
      context = Context.new(document, Reader.new(source))
      parse_header(context)
      parse_blocks(context)
      document
    end

    def parse_header(context)
      context.reader.skip_blank_lines
      parse_header_attributes(context)
      parse_document_title(context)
    end

    def parse_blocks(context)
      until context.reader.eof?
        BLOCK_CHAIN.handle(context)
      end
    end

    def parse_header_attributes(context)
      handler = BlockHandlers::AttributeEntry.new
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
