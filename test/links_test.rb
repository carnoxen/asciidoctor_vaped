# frozen_string_literal: true

require "test_helper"

class LinksTest < Minitest::Test
  def test_convert_renders_url_with_link_text
    html = AsciidoctorVaped.convert <<~ADOC, header_footer: false
      https://asciidoctor.org[Asciidoctor]
    ADOC

    assert_includes html, '<a href="https://asciidoctor.org">Asciidoctor</a>'
  end
end
