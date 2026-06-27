# frozen_string_literal: true

require "test_helper"

class DocumentTest < Minitest::Test
  def test_load_builds_document_header_and_section
    document = AsciidoctorVaped.load <<~ADOC, safe: :safe
      = Document Title
      :toc:

      == Section Title
    ADOC

    assert_kind_of AsciidoctorVaped::AST::Document, document
    assert_kind_of AsciidoctorVaped::AST::Node, document
    refute_kind_of AsciidoctorVaped::AST::Element, document
    assert_equal :document, document.context
    assert_equal "Document Title", document.doctitle
    assert_equal "", document.attributes["toc"]
    assert_equal "Section Title", document.sections.first.text
  end

  def test_parse_builds_document_title_and_attributes
    document = AsciidoctorVaped.parse <<~ADOC
      :toc: left
      = Document Title

      Body text.
    ADOC

    assert_equal "Document Title", document.doctitle
    assert_equal "left", document.attributes["toc"]
    assert_equal "Document Title", document.attributes["doctitle"]
  end

  def test_parse_builds_section_tree
    document = AsciidoctorVaped.parse <<~ADOC
      = Document Title

      == Level 1 Section

      === Level 2 Section
      Section content.
    ADOC

    section = document.sections.first
    nested = section.sections.first

    assert_equal "Level 1 Section", section.text
    assert_equal 1, section.attributes[:level]
    assert_equal "Level 2 Section", nested.text
    assert_equal 2, nested.attributes[:level]
    paragraph = nested.children.find do |child|
      child.respond_to?(:context) && child.context == :paragraph
    end
    assert_equal "Section content.", paragraph.text
  end

  def test_convert_hides_document_title_in_embedded_output
    html = AsciidoctorVaped.convert <<~ADOC, header_footer: false
      = Document Title

      == Section Title
    ADOC

    refute_includes html, "<h1>Document Title</h1>"
    assert_includes html, "<h2>Section Title</h2>"
  end
end
