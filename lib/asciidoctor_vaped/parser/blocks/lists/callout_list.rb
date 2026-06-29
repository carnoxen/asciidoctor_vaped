# frozen_string_literal: true

require_relative "../../common/base_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class CalloutList < BaseNode
        PATTERN = /\A<(?<number>\d+|\.)>\s+(?<text>.+)\z/

        def parse(context)
          automatic_number = 0
          items = context.reader.read_while { |line| line.match?(PATTERN) }.map do |line|
            match = line.match(PATTERN)
            number = match[:number]
            number = (automatic_number += 1).to_s if number == "."
            AST::Element.new(:callout, attributes: { number: }, children: Inline.parse(match[:text]))
          end
          context.append AST::Element.new(:colist, children: items)
        end
      end
    end
  end
end
