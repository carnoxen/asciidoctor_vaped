# frozen_string_literal: true

require_relative "delimited_block"

module AsciidoctorVaped
  module Parser
    module BlockHandlers
      class Table < DelimitedBlock
        def delimiter = "|==="

        def parse(context)
          table = AST::Node.new(:table)
          context.reader.read_delimited(delimiter).each do |line|
            next if line.strip == ""

            table << row(line)
          end
          context.append(table)
        end

        private

        def row(line)
          AST::Node.new(:table_row).tap do |row|
            line.sub(/\A\|/, "").split(/\s+\|/).each { |cell| row << AST::Node.new(:table_cell, text: cell.strip) }
          end
        end
      end
    end
  end
end
