# frozen_string_literal: true

require_relative "table_cell"

module AsciidoctorVaped
  module Parser
    module Blocks
      class TableRow
        def self.build(cells)
          AST::Element.new(:table_row, children: cells.map { |cell| TableCell.build(cell) })
        end
      end
    end
  end
end
