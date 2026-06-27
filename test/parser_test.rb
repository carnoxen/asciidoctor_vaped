# frozen_string_literal: true

require "test_helper"

class ParserTest < Minitest::Test
  def test_parse_treats_plain_text_as_strings
    document = AsciidoctorVaped.parse <<~ADOC
      Paragraph text.

      ----
      Listing text.
      ----
    ADOC

    paragraph, listing = document.children

    assert_equal ["Paragraph text."], paragraph.children
    assert_equal ["Listing text."], listing.children
    assert_equal "Paragraph text.", paragraph.text
    assert_equal "Listing text.", listing.text
  end
end
