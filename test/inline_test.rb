# frozen_string_literal: true

require "test_helper"

class InlineTest < Minitest::Test
  def test_parse_builds_inline_nodes
    document = AsciidoctorVaped.parse <<~ADOC
      A *strong* _emphasis_ `code` https://asciidoctor.org[Asciidoctor] text.
    ADOC

    paragraph = document.children.first

    assert_equal :paragraph, paragraph.context
    assert_empty paragraph.attributes
    assert_kind_of AsciidoctorVaped::AST::Element, paragraph
    assert_equal "A ", paragraph.children.first
    assert_equal ["A ", :strong, " ", :emphasis, " ", :monospace, " ", :link, " text."],
                 paragraph.children.map { |child| child.is_a?(String) ? child : child.context }
    assert_equal "strong", paragraph.children[1].text
    assert_equal "emphasis", paragraph.children[3].text
    assert_equal "code", paragraph.children[5].text
    assert_equal "https://asciidoctor.org", paragraph.children[7].attributes[:target]
    assert_equal "Asciidoctor", paragraph.children[7].text
    assert_same paragraph, paragraph.children[1].parent
  end

end
