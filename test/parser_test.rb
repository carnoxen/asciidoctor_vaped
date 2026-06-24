# frozen_string_literal: true

require "test_helper"

class ParserTest < Minitest::Test
  def test_load_accepts_quick_reference_document_header_and_list
    document = AsciidoctorVaped.load <<~ADOC, safe: :safe
      = Document Title
      :toc:

      == Section Title

      * Item 1
      * Item 2
    ADOC

    assert_kind_of AsciidoctorVaped::AST::Document, document
    assert_equal "Document Title", document.doctitle
    assert_equal "", document.attributes["toc"]
    assert_equal "Section Title", document.sections.first.text
    assert_equal ["Item 1", "Item 2"], document.sections.first.blocks.first.blocks.map(&:text)
  end

  def test_convert_accepts_quick_reference_url_with_link_text
    html = AsciidoctorVaped.convert <<~ADOC, header_footer: false
      = Document Title

      https://asciidoctor.org[Asciidoctor]
    ADOC

    assert_includes html, '<a href="https://asciidoctor.org">Asciidoctor</a>'
  end

  def test_convert_handles_quick_reference_block_examples_without_dependency
    html = AsciidoctorVaped.convert <<~ADOC, header_footer: false
      == Lists

      * Edgar Allan Poe
      * Sheri S. Tepper

      . Protons
      . Electrons

      [source,ruby]
      ----
      puts 'Hello, World!'
      ----

      |===
      |Name |Description
      |Firefox
      |Browser
      |===

      NOTE: An admonition paragraph draws the reader's attention.
    ADOC

    assert_includes html, '<div class="ulist">'
    assert_includes html, '<div class="olist">'
    assert_includes html, '<pre class="highlight"><code class="language-ruby" data-lang="ruby">'
    assert_includes html, '<table class="tableblock frame-all grid-all stretch">'
    assert_includes html, '<td class="icon">'
  end

  def test_parses_quick_reference_block_titles_and_delimited_blocks
    document = AsciidoctorVaped.parse <<~ADOC
      .Example Block
      ====
      Text inside.
      ====

      ....
      literal
      ....

      WARNING: Careful.
    ADOC

    example, literal, warning = document.blocks

    assert_equal :example, example.context
    assert_equal "Example Block", example.attributes[:title]
    assert_equal :literal, literal.context
    assert_equal "literal", literal.text
    assert_equal :admonition, warning.context
    assert_equal "WARNING", warning.attributes[:name]
  end

  def test_parses_quick_reference_document_title_and_attributes
    document = AsciidoctorVaped.parse <<~ADOC
      :toc: left
      = Document Title

      Body text.
    ADOC

    assert_equal "Document Title", document.doctitle
    assert_equal "left", document.attributes["toc"]
    assert_equal "Document Title", document.attributes["doctitle"]
  end

  def test_builds_quick_reference_section_tree
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
    assert_equal "Section content.", nested.blocks.first.text
  end

  def test_parses_quick_reference_listing_and_lists
    document = AsciidoctorVaped.parse <<~ADOC
      ----
      puts 'Hello, World!'
      ----

      * Edgar Allan Poe
      * Sheri S. Tepper

      . Protons
      . Electrons
    ADOC

    listing, unordered, ordered = document.blocks

    assert_equal :listing, listing.context
    assert_equal "puts 'Hello, World!'", listing.text
    assert_equal ["Edgar Allan Poe", "Sheri S. Tepper"], unordered.blocks.map(&:text)
    assert_equal %w[Protons Electrons], ordered.blocks.map(&:text)
  end
end
