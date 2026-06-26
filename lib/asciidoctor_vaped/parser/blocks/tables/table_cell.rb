# frozen_string_literal: true

module AsciidoctorVaped
  module Parser
    module Blocks
      class TableCell
        def self.build(text)
          AST::Node.new(:table_cell, text:, inline: true)
        end
      end
    end
  end
end
