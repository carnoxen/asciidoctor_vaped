# frozen_string_literal: true

module AsciidoctorVaped
  module Parser
    module Blocks
      class TableCell
        def self.build(text)
          AST::Element.new(:table_cell, children: Inline.parse(text))
        end
      end
    end
  end
end
