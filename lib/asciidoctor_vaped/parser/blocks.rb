# frozen_string_literal: true

require_relative "common/base_node"
require_relative "common/blank_line"
require_relative "common/comment"
require_relative "blocks/metadata/document_attribute"
require_relative "blocks/metadata/caption"
require_relative "blocks/metadata/element_attributes"
require_relative "blocks/heading"
require_relative "blocks/delimited/delimited_node"
require_relative "blocks/delimited/listing"
require_relative "blocks/delimited/literal"
require_relative "blocks/delimited/example"
require_relative "blocks/delimited/quote"
require_relative "blocks/delimited/sidebar"
require_relative "blocks/delimited/open"
require_relative "blocks/delimited/passthrough"
require_relative "blocks/tables/table_cell"
require_relative "blocks/tables/table_row"
require_relative "blocks/tables/table"
require_relative "blocks/admonition"
require_relative "blocks/media"
require_relative "blocks/lists/list_item"
require_relative "blocks/lists/list_base"
require_relative "blocks/lists/unordered_list"
require_relative "blocks/lists/ordered_list"
require_relative "blocks/lists/description_list"
require_relative "blocks/paragraph"

module AsciidoctorVaped
  module Parser
    module Blocks
      def self.chain(handlers)
        handlers.reverse.inject(nil) do |successor, handler|
          handler, kwargs = handler
          handler.new(successor, **(kwargs || {}))
        end
      end
    end
  end
end
