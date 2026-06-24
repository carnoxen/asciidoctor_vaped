# frozen_string_literal: true

require_relative "base_block"

module AsciidoctorVaped
  module Parser
    module BlockHandlers
      class ListBase < BaseBlock
        def parse(context)
          list = AST::Node.new(list_context)
          read_items(context).each { |item| list << item }
          context.append(list)
        end

        private

        def read_items(context)
          context.reader.read_while { |line| line.match?(pattern) }.map do |line|
            AST::Node.new(:list_item, text: line.sub(pattern, ""))
          end
        end
      end
    end
  end
end
