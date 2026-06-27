# frozen_string_literal: true

require "test_helper"

class ListsTest < Minitest::Test
  def test_parse_builds_unordered_and_ordered_lists
    document = AsciidoctorVaped.parse <<~ADOC
      * Edgar Allan Poe
      * Sheri S. Tepper

      . Protons
      . Electrons
    ADOC

    unordered, ordered = document.children

    assert_equal :ulist, unordered.context
    assert_equal :olist, ordered.context
    assert_equal ["Edgar Allan Poe", "Sheri S. Tepper"], unordered.children.map(&:text)
    assert_equal %w[Protons Electrons], ordered.children.map(&:text)
  end

  def test_parse_chains_list_items_to_inline_nodes
    document = AsciidoctorVaped.parse <<~ADOC
      * Use *strong* text
    ADOC

    item = document.children.first.children.first

    assert_equal :list_item, item.context
    assert_equal ["Use ", :strong, " text"],
                 item.children.map { |child| child.is_a?(String) ? child : child.context }
  end

  def test_convert_renders_simple_list_items_without_paragraphs
    html = AsciidoctorVaped.convert <<~ADOC, header_footer: false
      * Edgar Allan Poe
      * Sheri S. Tepper

      . Protons
      . Electrons
    ADOC

    assert_includes html, "<ul>"
    assert_includes html, "<ol>"
    refute_includes html, '<div class="ulist">'
    refute_includes html, '<div class="olist">'
    assert_includes html, "<li>Edgar Allan Poe</li>"
    refute_includes html, "<li><p>Edgar Allan Poe</p></li>"
    assert_includes html, "<li>Protons</li>"
    refute_includes html, "<li><p>Protons</p></li>"
  end
end
