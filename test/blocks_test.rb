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

  def test_parse_builds_media_blocks
    document = AsciidoctorVaped.parse <<~ADOC
      image::diagram.png[Architecture,640,480]
      audio::podcast.mp3[options="autoplay,loop"]
      video::dQw4w9WgXcQ[youtube]
    ADOC

    image, audio, video = document.children
    assert_equal [:image, :audio, :video], document.children.map(&:context)
    assert_equal({ target: "diagram.png", alt: "Architecture", width: "640", height: "480" }, image.attributes)
    assert_equal true, audio.attributes[:autoplay]
    assert_equal true, audio.attributes[:loop]
    assert_equal "youtube", video.attributes[:provider]
  end

end
