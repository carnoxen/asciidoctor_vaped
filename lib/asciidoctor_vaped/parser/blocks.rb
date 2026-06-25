# frozen_string_literal: true

require_relative "blocks/base_node"
require_relative "blocks/blank_line"
require_relative "blocks/attribute_entry"
require_relative "blocks/block_title"
require_relative "blocks/attribute_list"
require_relative "blocks/comment"
require_relative "blocks/section"
require_relative "blocks/delimited_node"
require_relative "blocks/listing"
require_relative "blocks/literal"
require_relative "blocks/example"
require_relative "blocks/quote"
require_relative "blocks/sidebar"
require_relative "blocks/table"
require_relative "blocks/admonition"
require_relative "blocks/list_base"
require_relative "blocks/unordered_list"
require_relative "blocks/ordered_list"
require_relative "blocks/paragraph"

module AsciidoctorVaped
  module Parser
    module Blocks
      def self.chain(handlers)
        handlers.reverse.inject(nil) { |successor, handler| handler.new(successor) }
      end
    end
  end
end
