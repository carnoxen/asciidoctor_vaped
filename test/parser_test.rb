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
    list = document.sections.first.children.find { |child| child.context == :ulist }
    assert_equal ["Item 1", "Item 2"], list.children.map(&:text)
  end

  def test_convert_accepts_quick_reference_url_with_link_text
    html = AsciidoctorVaped.convert <<~ADOC, header_footer: false
      = Document Title

      https://asciidoctor.org[Asciidoctor]
    ADOC

    assert_includes html, '<a href="https://asciidoctor.org">Asciidoctor</a>'
  end

  def test_parse_builds_inline_nodes
    document = AsciidoctorVaped.parse <<~ADOC
      A *strong* _emphasis_ `code` https://asciidoctor.org[Asciidoctor] text.
    ADOC

    paragraph = document.children.first

    assert_equal :paragraph, paragraph.context
    assert_equal %i[text strong text emphasis text monospace text link text], paragraph.children.map(&:context)
    assert_equal "strong", paragraph.children[1].text
    assert_equal "emphasis", paragraph.children[3].text
    assert_equal "code", paragraph.children[5].text
    assert_equal "https://asciidoctor.org", paragraph.children[7].attributes[:target]
    assert_equal "Asciidoctor", paragraph.children[7].text
    assert_same paragraph, paragraph.children[1].parent
  end

  def test_convert_renders_parsed_inline_nodes
    html = AsciidoctorVaped.convert <<~ADOC, header_footer: false
      * Use *strong*, _emphasis_, and `code`
    ADOC

    assert_includes html, "<li>Use <strong>strong</strong>, <em>emphasis</em>, and <code>code</code></li>"
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
    assert_includes html, "<li>Edgar Allan Poe</li>"
    refute_includes html, "<li><p>Edgar Allan Poe</p></li>"
    assert_includes html, "<li>Protons</li>"
    refute_includes html, "<li><p>Protons</p></li>"
    assert_includes html, '<pre class="highlight"><code class="language-ruby" data-lang="ruby">'
    assert_includes html, '<table class="tableblock frame-all grid-all stretch">'
    assert_includes html, "<tr>\n<td class=\"tableblock halign-left valign-top\"><p class=\"tableblock\">Firefox</p></td>\n<td class=\"tableblock halign-left valign-top\"><p class=\"tableblock\">Browser</p></td>\n</tr>"
    assert_includes html, '<td class="icon">'
  end

  def test_parses_quick_reference_block_titles_and_delimited_nodes
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

    example, literal, warning = document.children

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
    paragraph = nested.children.find { |child| child.context == :paragraph }
    assert_equal "Section content.", paragraph.text
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

    listing, unordered, ordered = document.children

    assert_equal :listing, listing.context
    assert_equal "puts 'Hello, World!'", listing.text
    assert_equal ["Edgar Allan Poe", "Sheri S. Tepper"], unordered.children.map(&:text)
    assert_equal %w[Protons Electrons], ordered.children.map(&:text)
  end
end
