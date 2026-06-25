# frozen_string_literal: true

require_relative "base_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class ListBase < BaseNode
        def match?(context)
          context.reader.peek&.match?(pattern)
        end

        def parse(context)
          list = AST::Node.new(list_context)
          read_items(context).each { |item| list << item }
          context.append(list)
        end

        private

        def read_items(context)
          context.reader.read_while { |line| line.match?(pattern) }.map do |line|
            AST::Node.new(:list_item, text: line.sub(pattern, ""), inline: true)
          end
        end
      end
    end
  end
end
