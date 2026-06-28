# frozen_string_literal: true

require "test_helper"

class TablesTest < Minitest::Test
  def test_parse_chains_table_rows_to_cells_to_inline_nodes
    document = AsciidoctorVaped.parse <<~ADOC
      |===
      |Name |*Description*
      |===
    ADOC

    row = document.children.first.children.first
    name, description = row.children

    assert_equal :table_row, row.context
    assert_equal :table_cell, name.context
    assert_equal :table_cell, description.context
    assert_equal %i[strong], description.children.map(&:context)
  end

  def test_parse_recognizes_explicit_header_option
    table = AsciidoctorVaped.parse(<<~ADOC).children.first
      [options="header"]
      |===
      |Name |Description
      |Firefox |Browser
      |===
    ADOC

    assert_equal true, table.attributes[:header]
  end

end
