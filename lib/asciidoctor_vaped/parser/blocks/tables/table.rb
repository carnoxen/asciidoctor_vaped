# frozen_string_literal: true

require_relative "../delimited/delimited_node"
require_relative "table_row"

module AsciidoctorVaped
  module Parser
    module Blocks
      class Table < DelimitedNode
        DELIMITER = "|==="

        def parse(context)
          table = AST::Element.new(:table)
          rows(context.reader.read_delimited(DELIMITER)).each { |cells| table << TableRow.build(cells) }
          context.append(table)
        end

        private

        def rows(lines)
          columns = nil
          pending = []
          rows = []

          lines.each do |line|
            cells = cells_for(line)
            next if cells.empty?

            if cells.length > 1
              columns ||= cells.length
              flush_pending(rows, pending, columns)
              cells.each_slice(columns) { |row| rows << row }
            elsif columns
              pending.concat(cells)
              flush_pending(rows, pending, columns)
            else
              rows << cells
            end
          end

          rows << pending unless pending.empty?
          rows
        end

        def flush_pending(rows, pending, columns)
          rows << pending.shift(columns) while pending.length >= columns
        end

        def cells_for(line)
          return [] if line.strip == ""

          line.sub(/\A\|/, "").split(/\s+\|/).map(&:strip)
        end

      end
    end
  end
end
