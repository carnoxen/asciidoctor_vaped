# frozen_string_literal: true

require "test_helper"

class DocBookConverterTest < Minitest::Test
  def test_renders_compound_blocks_from_child_structure
    docbook = convert <<~ADOC
      ____
      Quote with *strong* text.
      ____
    ADOC

    assert_includes docbook, "<blockquote>"
    assert_includes docbook, '<para>Quote with <emphasis role="strong">strong</emphasis> text.</para>'
  end

  def test_renders_table_header
    docbook = convert <<~ADOC
      [%header]
      |===
      |Name |Description
      |Firefox |Browser
      |===
    ADOC

    assert_includes docbook, "<thead>\n<row><entry>Name</entry><entry>Description</entry></row>\n</thead>"
    assert_includes docbook, "<tbody>\n<row><entry>Firefox</entry><entry>Browser</entry></row>\n</tbody>"
  end

  def test_renders_media_blocks
    docbook = convert <<~ADOC
      .Architecture
      image::diagram.png[Diagram,640,480]

      audio::podcast.mp3[]

      video::demo.mp4[width=640]
    ADOC

    assert_includes docbook, '<mediaobject><imageobject><imagedata fileref="diagram.png" width="640" depth="480"></imagedata></imageobject><textobject><phrase>Diagram</phrase></textobject><caption><para>Architecture</para></caption></mediaobject>'
    assert_includes docbook, '<mediaobject><audioobject><audiodata fileref="podcast.mp3"></audiodata></audioobject></mediaobject>'
    assert_includes docbook, '<mediaobject><videoobject><videodata fileref="demo.mp4" width="640"></videodata></videoobject></mediaobject>'
  end

  def test_applies_imagesdir_to_relative_block_images
    docbook = convert <<~ADOC
      :imagesdir: assets/images

      image::diagram.png[]
    ADOC

    assert_includes docbook, 'fileref="assets/images/diagram.png"'
  end

  def test_renders_nested_and_description_lists
    docbook = convert <<~ADOC
      . Parent
      .. Child

      Term:: Description
      Nested::: Definition
    ADOC

    assert_includes docbook, "<listitem><para>Parent</para>\n<orderedlist>"
    assert_includes docbook, "<listitem><para>Child</para></listitem>"
    assert_includes docbook, "<variablelist>"
    assert_includes docbook, "<varlistentry><term>Term</term><listitem><para>Description</para>\n<variablelist>"
  end

  def test_renders_semantic_source_callouts
    docbook = convert <<~ADOC
      [source,ruby]
      ----
      puts "hello" # <1>
      ----
      <1> Prints a greeting.
    ADOC

    assert_includes docbook, 'puts &quot;hello&quot; <co xml:id="CO1-1"></co>'
    assert_includes docbook, '<callout arearefs="CO1-1"><para>Prints a greeting.</para></callout>'
  end

  private

  def convert(source)
    AsciidoctorVaped.convert(source, backend: :docbook)
  end
end
