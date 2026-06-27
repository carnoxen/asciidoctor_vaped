# frozen_string_literal: true

require "test_helper"

class BlocksTest < Minitest::Test
  def test_parse_builds_listing
    document = AsciidoctorVaped.parse <<~ADOC
      ----
      puts 'Hello, World!'
      ----
    ADOC

    listing = document.children.first

    assert_equal :listing, listing.context
    assert_equal "puts 'Hello, World!'", listing.text
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
    assert_equal ["Quote with ", :strong, " text."],
                 paragraph.children.map { |child| child.is_a?(String) ? child : child.context }
    assert_equal :ulist, list.context
    assert_equal "Nested item", list.children.first.text
  end

  def test_parse_builds_captions_and_delimited_nodes
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

  def test_parse_builds_common_delimited_blocks
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

  def test_convert_html_renders_compound_blocks_from_child_structure
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
    assert_includes docbook, '<para>Quote with <emphasis role="strong">strong</emphasis> text.</para>'
  end

  def test_convert_renders_source_listing
    html = AsciidoctorVaped.convert <<~ADOC, header_footer: false
      [source,ruby]
      ----
      puts 'Hello, World!'
      ----
    ADOC

    assert_includes html, '<pre class="highlight"><samp class="language-ruby" data-lang="ruby">'
  end

  def test_convert_renders_admonition_without_table_markup
    html = AsciidoctorVaped.convert <<~ADOC, header_footer: false
      NOTE: An admonition paragraph draws the reader's attention.
    ADOC

    assert_includes html, '<article class="admonitionblock note">'
    refute_includes html, '<td class="icon">'
    refute_includes html, '<div class="content">'
  end

  def test_convert_renders_passthrough_and_open_blocks
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

  def test_convert_renders_delimited_nodes_with_titles
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

    %w[listing literal example quote].each do |name|
      assert_includes html, %(<figure class="#{name}block">)
      assert_includes html, %(<figcaption class="title">#{name.capitalize}</figcaption>)
    end

    assert_includes html, "<aside>"
    assert_includes html, "<h2>Sidebar</h2>"
    assert_includes html, "<p>sidebar</p>"
    refute_includes html, "<aside class="
    refute_includes html, '<figure class="sidebarblock">'
    refute_includes html, '<figcaption class="title">Sidebar</figcaption>'
    refute_includes html, '<div class="content">'
  end
end
