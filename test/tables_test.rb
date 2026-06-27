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

  def test_convert_renders_table
    html = AsciidoctorVaped.convert <<~ADOC, header_footer: false
      |===
      |Name |Description
      |Firefox
      |Browser
      |===
    ADOC

    assert_includes html, '<table class="tableblock frame-all grid-all stretch">'
    assert_includes html, "<tr>\n<td class=\"tableblock halign-left valign-top\">Firefox</td>\n<td class=\"tableblock halign-left valign-top\">Browser</td>\n</tr>"
  end
end
