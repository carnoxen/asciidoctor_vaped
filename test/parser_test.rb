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
    assert_kind_of AsciidoctorVaped::AST::Node, document
    refute_kind_of AsciidoctorVaped::AST::Element, document
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
    assert_kind_of AsciidoctorVaped::AST::Element, paragraph
    assert_kind_of AsciidoctorVaped::AST::Text, paragraph.children.first
    assert_equal "A ", paragraph.children.first.value
    refute_respond_to paragraph.children.first, :attributes
    assert_equal %i[text strong text emphasis text monospace text link text], paragraph.children.map(&:context)
    assert_equal "strong", paragraph.children[1].text
    assert_equal "emphasis", paragraph.children[3].text
    assert_equal "code", paragraph.children[5].text
    assert_equal "https://asciidoctor.org", paragraph.children[7].attributes[:target]
    assert_equal "Asciidoctor", paragraph.children[7].text
    assert_same paragraph, paragraph.children[1].parent
  end

  def test_parse_treats_plain_text_as_nodes
    document = AsciidoctorVaped.parse <<~ADOC
      Paragraph text.

      ----
      Listing text.
      ----
    ADOC

    paragraph, listing = document.children

    assert_equal [:text], paragraph.children.map(&:context)
    assert_equal [:text], listing.children.map(&:context)
    assert_equal "Paragraph text.", paragraph.text
    assert_equal "Listing text.", listing.text
  end

  def test_parse_chains_list_items_to_inline_nodes
    document = AsciidoctorVaped.parse <<~ADOC
      * Use *strong* text
    ADOC

    item = document.children.first.children.first

    assert_equal :list_item, item.context
    assert_equal %i[text strong text], item.children.map(&:context)
  end

  def test_parse_chains_quote_blocks_to_child_blocks_and_inline_nodes
    document = AsciidoctorVaped.parse <<~ADOC
      ____
      Quote with *strong* text.

      * Nested item
      ____
    ADOC

    quote = document.children.first
    paragraph, list = quote.children

    assert_equal :quote, quote.context
    assert_equal :paragraph, paragraph.context
    assert_equal %i[text strong text], paragraph.children.map(&:context)
    assert_equal :ulist, list.context
    assert_equal "Nested item", list.children.first.text
  end

  def test_convert_renders_parsed_inline_nodes
    html = AsciidoctorVaped.convert <<~ADOC, header_footer: false
      * Use *strong*, _emphasis_, and `code`
    ADOC

    assert_includes html, "<li>Use <strong>strong</strong>, <em>emphasis</em>, and <code>code</code></li>"
  end

  def test_convert_renders_compound_blocks_from_child_structure
    html = AsciidoctorVaped.convert <<~ADOC, header_footer: false
      ____
      Quote with *strong* text.

      * Nested item
      ____
    ADOC

    assert_includes html, '<figure class="quoteblock">'
    assert_includes html, "<blockquote>"
    assert_includes html, "<p>Quote with <strong>strong</strong> text.</p>"
    assert_includes html, "</blockquote>"
    assert_includes html, "<li>Nested item</li>"
  end

  def test_convert_docbook_renders_compound_blocks_from_child_structure
    docbook = AsciidoctorVaped.convert <<~ADOC, backend: :docbook
      ____
      Quote with *strong* text.
      ____
    ADOC

    assert_includes docbook, "<blockquote>"
    assert_includes docbook, "<para>Quote with <emphasis role=\"strong\">strong</emphasis> text.</para>"
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
    assert_includes html, '<pre class="highlight"><samp class="language-ruby" data-lang="ruby">'
    assert_includes html, '<table class="tableblock frame-all grid-all stretch">'
    assert_includes html, "<tr>\n<td class=\"tableblock halign-left valign-top\">Firefox</td>\n<td class=\"tableblock halign-left valign-top\">Browser</td>\n</tr>"
    assert_includes html, '<article class="admonitionblock note">'
    refute_includes html, '<td class="icon">'
  end

  def test_parses_quick_reference_captions_and_delimited_nodes
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

  def test_parses_common_quick_reference_delimited_blocks
    document = AsciidoctorVaped.parse <<~ADOC
      ****
      sidebar
      ****

      ____
      quote
      ____

      ++++
      <raw>passthrough</raw>
      ++++

      --
      open block
      --

      [NOTE]
      ====
      compound note
      ====
    ADOC

    sidebar, quote, pass, open, note = document.children

    assert_equal :sidebar, sidebar.context
    assert_equal :quote, quote.context
    assert_equal :pass, pass.context
    assert_equal :open, open.context
    assert_equal :admonition, note.context
    assert_equal "NOTE", note.attributes[:name]
  end

  def test_converts_passthrough_and_open_blocks
    html = AsciidoctorVaped.convert <<~ADOC, header_footer: false
      .Passthrough
      +++
      <strong>raw</strong>
      +++

      .Open
      --
      open block
      --
    ADOC

    assert_includes html, '<figure class="passblock">'
    assert_includes html, '<figcaption class="title">Passthrough</figcaption>'
    assert_includes html, "<strong>raw</strong>"
    assert_includes html, '<figure class="openblock">'
    assert_includes html, '<figcaption class="title">Open</figcaption>'
    assert_includes html, "open block"
  end

  def test_converts_delimited_nodes_to_figures_with_figcaptions
    html = AsciidoctorVaped.convert <<~ADOC, header_footer: false
      .Listing
      ----
      listing
      ----

      .Literal
      ....
      literal
      ....

      .Example
      ====
      example
      ====

      .Quote
      ____
      quote
      ____

      .Sidebar
      ****
      sidebar
      ****
    ADOC

    %w[listing literal example quote sidebar].each do |name|
      assert_includes html, %(<figure class="#{name}block">)
      assert_includes html, %(<figcaption class="title">#{name.capitalize}</figcaption>)
    end
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
end
