# frozen_string_literal: true

require "test_helper"

class CalloutsTest < Minitest::Test
  def test_extracts_supported_callout_guards_and_positions
    extraction = AsciidoctorVaped::Callouts.extract <<~SOURCE.chomp
      first // <1>
      second # <2>
      third ;; <3>
      fourth <!--4-->
    SOURCE

    assert_equal "first \nsecond \nthird \nfourth ", extraction.source
    assert_equal %w[1 2 3 4], extraction.marks.map(&:number)
    assert_equal [6, 14, 21, 29], extraction.marks.map(&:position)
  end

  def test_preserves_spaces_before_callout_suffix
    extraction = AsciidoctorVaped::Callouts.extract("value   # <1>")

    assert_equal "value   ", extraction.source
    assert_equal 8, extraction.marks.first.position
  end

  def test_preserves_escaped_callout
    extraction = AsciidoctorVaped::Callouts.extract("value \\<1>")

    assert_equal "value <1>", extraction.source
    assert_empty extraction.marks
  end
end
