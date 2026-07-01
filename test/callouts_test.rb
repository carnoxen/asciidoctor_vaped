# frozen_string_literal: true

require "test_helper"

class CalloutsTest < Minitest::Test
  def test_extracts_callouts_without_consuming_comment_syntax
    extraction = AsciidoctorVaped::Callouts.extract <<~SOURCE.chomp
      first // <1>
      second # <2>
      third ;; <3>
      fourth <!-- <.> -->
    SOURCE

    assert_equal "first // \nsecond # \nthird ;; \nfourth <!--  -->", extraction.source
    assert_equal %w[1 2 3 1], extraction.marks.map(&:number)
    assert_equal [9, 19, 29, 42], extraction.marks.map(&:position)
  end

  def test_extracts_callouts_anywhere_in_source
    extraction = AsciidoctorVaped::Callouts.extract("before <1> after # <2>")

    assert_equal "before  after # ", extraction.source
    assert_equal [7, 16], extraction.marks.map(&:position)
  end

  def test_does_not_support_legacy_xml_callout_syntax
    extraction = AsciidoctorVaped::Callouts.extract("value <!--1-->")

    assert_equal "value <!--1-->", extraction.source
    assert_empty extraction.marks
  end

  def test_preserves_escaped_callout
    extraction = AsciidoctorVaped::Callouts.extract("value \\<1>")

    assert_equal "value <1>", extraction.source
    assert_empty extraction.marks
  end
end
