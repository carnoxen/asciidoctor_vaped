# frozen_string_literal: true

require "test_helper"

class HTMLConverterTest < Minitest::Test
  def test_hides_document_title_in_embedded_output
    html = convert <<~ADOC
      = Document Title

      == Section Title
    ADOC

    refute_includes html, "<h1>Document Title</h1>"
    assert_includes html, "<h2>Section Title</h2>"
  end

  def test_renders_only_document_title_group_in_standalone_output
    html = AsciidoctorVaped.convert <<~ADOC
      = Document Title

      Body text.
    ADOC

    assert_includes html, "<hgroup>\n<h1>Document Title</h1>\n</hgroup>"
    refute_includes html, "<title>"
  end

  def test_renders_section_levels_as_h2_through_h6
    html = convert <<~ADOC
      == Level 1
      === Level 2
      ==== Level 3
      ===== Level 4
      ====== Level 5
    ADOC

    (1..5).each { |level| assert_includes html, "<h#{level + 1}>Level #{level}</h#{level + 1}>" }
  end

  def test_renders_document_subtitle_in_title_group
    html = AsciidoctorVaped.convert <<~ADOC
      = Main Title: Continued: Subtitle

      Body text.
    ADOC

    assert_includes html, "<hgroup>\n<h1>Main Title: Continued</h1>\n<p>Subtitle</p>\n</hgroup>"
  end

  def test_uses_custom_document_title_separator
    html = AsciidoctorVaped.convert <<~ADOC
      = Main Title:: Subtitle
      :title-separator: ::

      Body text.
    ADOC

    assert_includes html, "<hgroup>\n<h1>Main Title</h1>\n<p>Subtitle</p>\n</hgroup>"
  end

  def test_renders_compound_blocks_from_child_structure
    html = convert <<~ADOC
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

  def test_renders_source_listing
    html = convert <<~ADOC
      [source,ruby]
      ----
      puts 'Hello, World!'
      ----
    ADOC

    assert_includes html, '<pre class="highlight"><code class="language-ruby" data-lang="ruby">'
  end

  def test_renders_source_callouts_and_callout_list
    html = convert <<~ADOC
      [source,ruby]
      ----
      puts "hello" # <.>
      puts "again" # <.>
      ----
      <1> Prints a greeting.
      <2> Prints another greeting.
    ADOC

    assert_includes html, 'puts &quot;hello&quot;<i class="conum" data-value="1"></i><b>(1)</b>'
    assert_includes html, 'puts &quot;again&quot;<i class="conum" data-value="2"></i><b>(2)</b>'
    assert_includes html, '<div class="colist arabic"><ol>'
    assert_includes html, '<li data-value="1"><p>Prints a greeting.</p></li>'
    assert_includes html, '<li data-value="2"><p>Prints another greeting.</p></li>'
  end

  def test_highlightjs_is_default_and_adds_assets_to_standalone_output
    html = AsciidoctorVaped.convert <<~ADOC
      [source,ruby]
      ----
      puts "hello"
      ----
    ADOC

    assert_includes html, "highlight.js/11.11.1/styles/github.min.css"
    assert_includes html, "highlight.js/11.11.1/highlight.min.js"
    assert_includes html, "hljs.highlightElement(code)"
  end

  def test_highlightjs_can_load_assets_from_a_local_directory
    html = AsciidoctorVaped.convert <<~ADOC
      :highlightjsdir: highlightjs

      [source,ruby]
      ----
      puts "hello"
      ----
    ADOC

    assert_includes html, 'href="highlightjs/styles/github.min.css"'
    assert_includes html, 'src="highlightjs/highlight.min.js"'
  end

  def test_rouge_highlighter_is_selected_by_document_attribute
    require "rouge"
    html = convert <<~ADOC
      :syntax-highlighter: rouge

      [source,ruby]
      ----
      puts "hello" # <1>
      ----
      <1> Prints a greeting.
    ADOC

    assert_includes html, '<span style='
    assert_includes html, '<i class="conum" data-value="1"></i><b>(1)</b>'
  rescue LoadError
    skip "Rouge is optional"
  end

  def test_pygments_highlighter_is_selected_by_document_attribute
    html = convert <<~ADOC
      :syntax-highlighter: pygments

      [source,ruby]
      ----
      puts "hello" # <1>
      ----
      <1> Prints a greeting.
    ADOC

    assert_includes html, '<span style='
    assert_includes html, '<i class="conum" data-value="1"></i><b>(1)</b>'
  end

  def test_renders_media_blocks
    html = convert <<~ADOC
      .Architecture
      image::diagram.png[Diagram,640,480]

      audio::podcast.mp3[options="autoplay,loop"]

      video::demo.mp4[width=640,start=10,end=60]

      video::dQw4w9WgXcQ[youtube]
    ADOC

    assert_includes html, '<figure class="imageblock">'
    assert_includes html, '<img width="640" height="480" src="diagram.png" alt="Diagram">'
    assert_includes html, '<figcaption class="title">Architecture</figcaption>'
    assert_includes html, '<audio controls="true" autoplay="true" loop="true" src="podcast.mp3"></audio>'
    assert_includes html, '<video controls="true" width="640" src="demo.mp4#t=10,60"></video>'
    assert_includes html, '<iframe src="https://www.youtube.com/embed/dQw4w9WgXcQ" allowfullscreen="true"></iframe>'
  end

  def test_applies_imagesdir_to_relative_block_images
    html = convert <<~ADOC
      :imagesdir: assets/images

      image::diagram.png[]
    ADOC

    assert_includes html, 'src="assets/images/diagram.png"'
    assert_includes html, 'alt="diagram"'
  end

  def test_renders_admonition_without_table_markup
    html = convert "NOTE: An admonition paragraph draws the reader's attention."

    assert_includes html, '<article class="admonitionblock note">'
    refute_includes html, '<td class="icon">'
    refute_includes html, '<div class="content">'
  end

  def test_renders_admonition_title_as_h2
    html = convert <<~ADOC
      .Important note
      NOTE: Read this.
    ADOC

    assert_includes html, '<h2 class="title">Important note</h2>'
    refute_includes html, '<div class="title">'
  end

  def test_renders_passthrough_and_open_blocks
    html = convert <<~ADOC
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

  def test_renders_delimited_nodes_with_titles
    html = convert <<~ADOC
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

  def test_renders_table
    html = convert <<~ADOC
      |===
      |Name |Description
      |Firefox
      |Browser
      |===
    ADOC

    assert_includes html, '<table class="tableblock frame-all grid-all stretch">'
    assert_includes html, "<tr>\n<td class=\"tableblock halign-left valign-top\">Firefox</td>\n<td class=\"tableblock halign-left valign-top\">Browser</td>\n</tr>"
  end

  def test_renders_explicit_table_header
    html = convert <<~ADOC
      [%header]
      |===
      |Name |Description
      |Firefox |Browser
      |===
    ADOC

    assert_includes html, "<thead>\n<tr>\n<th class=\"tableblock halign-left valign-top\">Name</th>\n<th class=\"tableblock halign-left valign-top\">Description</th>\n</tr>\n</thead>"
    assert_includes html, "<tbody>\n<tr>\n<td class=\"tableblock halign-left valign-top\">Firefox</td>"
  end

  def test_renders_implicit_table_header
    html = convert <<~ADOC
      |===
      |Name |Description

      |Firefox |Browser
      |===
    ADOC

    assert_includes html, "<thead>"
    assert_includes html, ">Name</th>"
  end

  def test_noheader_disables_implicit_table_header
    html = convert <<~ADOC
      [%noheader]
      |===
      |Name |Description

      |Firefox |Browser
      |===
    ADOC

    refute_includes html, "<thead>"
    assert_includes html, ">Name</td>"
  end

  def test_renders_simple_list_items_without_paragraphs
    html = convert <<~ADOC
      * Edgar Allan Poe
      * Sheri S. Tepper

      . Protons
      . Electrons
    ADOC

    assert_includes html, "<ul>"
    assert_includes html, "<ol>"
    refute_includes html, '<div class="ulist">'
    refute_includes html, '<div class="olist">'
    assert_includes html, "<li>Edgar Allan Poe</li>"
    refute_includes html, "<li><p>Edgar Allan Poe</p></li>"
    assert_includes html, "<li>Protons</li>"
    refute_includes html, "<li><p>Protons</p></li>"
  end

  def test_renders_parsed_inline_nodes
    html = convert "* Use *strong*, _emphasis_, and `code`"

    assert_includes html, "<li>Use <strong>strong</strong>, <em>emphasis</em>, and <code>code</code></li>"
  end

  def test_renders_nested_and_description_lists
    html = convert <<~ADOC
      * Parent
      ** Child

      Term:: Description
      Nested::: Definition
    ADOC

    assert_includes html, "<li>Parent\n<ul>\n<li>Child</li>\n</ul></li>"
    assert_includes html, "<dl>"
    assert_includes html, "<dt>Term</dt>\n<dd>Description\n<dl>"
    assert_includes html, "<dt>Nested</dt>\n<dd>Definition</dd>"
  end

  def test_renders_url_with_link_text
    html = convert "https://asciidoctor.org[Asciidoctor]"

    assert_includes html, '<a href="https://asciidoctor.org">Asciidoctor</a>'
  end

  private

  def convert(source)
    AsciidoctorVaped.convert(source, header_footer: false)
  end
end
