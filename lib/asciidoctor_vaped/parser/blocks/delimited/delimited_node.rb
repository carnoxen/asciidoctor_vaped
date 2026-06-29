# frozen_string_literal: true

require_relative "../../common/base_node"
require_relative "../admonition"

module AsciidoctorVaped
  module Parser
    module Blocks
      class DelimitedNode < BaseNode
        def match?(context)
          delimiters.include?(context.reader.peek)
        end

        def parse(context)
          lines = context.reader.read_delimited(context.reader.peek)
          node = build_node(context, lines)
          context.append node
        end

        def delimiters
          [delimiter]
        end

        def delimiter
          self.class::DELIMITER
        end

        def attributes(context)
          return {} unless admonition?(context)

          { name: context.pending_attributes[:style].to_s.upcase }
        end

        def context_name(context)
          admonition?(context) ? :admonition : default_context_name
        end

        private

        def build_node(context, lines)
          text = lines.join("\n")
          return AST::Element.new(context_name(context), attributes: attributes(context), children: parse_children(context, lines)) if compound?(context)

          AST::Element.new(context_name(context), attributes: attributes(context), children: [text])
        end

        def parse_children(context, lines)
          node = AST::Element.new(context_name(context), attributes: attributes(context))
          Parser.parse_nodes context.nested(node, Reader.new(lines.join("\n")))
          node.children
        end

        def compound?(context)
          admonition?(context)
        end

        def admonition?(context)
          Admonition.name? context.pending_attributes[:style]
        end

        def default_context_name
          self.class::CONTEXT
        end
      end

      class CompoundDelimitedNode < DelimitedNode
        private

        def compound?(_context) = true
      end
    end
  end
end
