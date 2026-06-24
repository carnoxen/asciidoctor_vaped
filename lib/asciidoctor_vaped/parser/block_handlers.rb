# frozen_string_literal: true

require_relative "block_handlers/base"
require_relative "block_handlers/blank_line"
require_relative "block_handlers/attribute_entry"
require_relative "block_handlers/block_title"
require_relative "block_handlers/attribute_list"
require_relative "block_handlers/comment"
require_relative "block_handlers/section"
require_relative "block_handlers/delimited_block"
require_relative "block_handlers/listing"
require_relative "block_handlers/literal"
require_relative "block_handlers/example"
require_relative "block_handlers/quote"
require_relative "block_handlers/sidebar"
require_relative "block_handlers/table"
require_relative "block_handlers/admonition"
require_relative "block_handlers/list_base"
require_relative "block_handlers/unordered_list"
require_relative "block_handlers/ordered_list"
require_relative "block_handlers/paragraph"

module AsciidoctorVaped
  module Parser
    module BlockHandlers
      def self.chain(handlers)
        handlers.reverse.inject(nil) { |successor, handler| handler.new(successor) }
      end
    end
  end
end
