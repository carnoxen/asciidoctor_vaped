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

  def test_convert_renders_explicit_header
    html = AsciidoctorVaped.convert <<~ADOC, header_footer: false
      [%header]
      |===
      |Name |Description
      |Firefox |Browser
      |===
    ADOC

    assert_includes html, "<thead>\n<tr>\n<th class=\"tableblock halign-left valign-top\">Name</th>\n<th class=\"tableblock halign-left valign-top\">Description</th>\n</tr>\n</thead>"
    assert_includes html, "<tbody>\n<tr>\n<td class=\"tableblock halign-left valign-top\">Firefox</td>"
  end

  def test_convert_renders_implicit_header
    html = AsciidoctorVaped.convert <<~ADOC, header_footer: false
      |===
      |Name |Description

      |Firefox |Browser
      |===
    ADOC

    assert_includes html, "<thead>"
    assert_includes html, ">Name</th>"
  end

  def test_noheader_disables_implicit_header
    html = AsciidoctorVaped.convert <<~ADOC, header_footer: false
      [%noheader]
      |===
      |Name |Description

      |Firefox |Browser
      |===
    ADOC

    refute_includes html, "<thead>"
    assert_includes html, ">Name</td>"
  end

  def test_convert_docbook_renders_header
    docbook = AsciidoctorVaped.convert <<~ADOC, backend: :docbook
      [%header]
      |===
      |Name |Description
      |Firefox |Browser
      |===
    ADOC

    assert_includes docbook, "<thead>\n<row><entry>Name</entry><entry>Description</entry></row>\n</thead>"
    assert_includes docbook, "<tbody>\n<row><entry>Firefox</entry><entry>Browser</entry></row>\n</tbody>"
  end
end
