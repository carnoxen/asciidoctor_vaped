# frozen_string_literal: true

require_relative "../common/base_node"

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

          AST::Element.new(context_name(context), attributes: attributes(context), children: [Inline.text_node(text)])
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
          context.pending_attributes[:style]&.to_s&.match?(/\A(?:NOTE|TIP|IMPORTANT|WARNING|CAUTION)\z/i)
        end

        def default_context_name
          raise NotImplementedError, "#{self.class} must implement #default_context_name"
        end
      end
    end
  end
end
