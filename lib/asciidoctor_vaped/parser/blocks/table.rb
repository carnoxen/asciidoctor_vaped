# frozen_string_literal: true

require_relative "delimited_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class Table < DelimitedNode
        def delimiter = "|==="

        def parse(context)
          table = AST::Node.new(:table)
          rows(context.reader.read_delimited(delimiter)).each { |cells| table << row(cells) }
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

        def row(cells)
          AST::Node.new(:table_row).tap do |row|
            cells.each { |cell| row << AST::Node.new(:table_cell, text: cell, inline: true) }
          end
        end
      end
    end
  end
end
