# frozen_string_literal: true

require "test_helper"

class AttributeListTest < Minitest::Test
  def test_quick_reference_source_block_attributes_set_style_and_language
    listing = parse_first_block <<~ADOC
      [source,ruby]
      ----
      puts 'Hello, World!'
      ----
    ADOC

    assert_equal :listing, listing.context
    assert_equal :source, listing.attributes[:style]
    assert_equal "ruby", listing.attributes[:language]
  end

  def test_quick_reference_source_block_options_are_preserved
    listing = parse_first_block <<~ADOC
      [source,python,linenums,start=5]
      ----
      print("Hello, World!")
      ----
    ADOC

    assert_equal "python", listing.attributes[:language]
    assert_equal true, listing.attributes[:linenums]
    assert_equal "5", listing.attributes[:start]
  end

  def test_quoted_block_attribute_values_may_contain_commas
    block = parse_first_block <<~ADOC
      [quote,attribution="Ada, Countess of Lovelace"]
      ____
      That brain of mine is something more than merely mortal.
      ____
    ADOC

    assert_equal :quote, block.context
    assert_equal :quote, block.attributes[:style]
    assert_equal "Ada, Countess of Lovelace", block.attributes[:attribution]
  end

  def test_quick_reference_shorthand_id_role_and_options_are_parsed
    paragraph = parse_first_block <<~ADOC
      [.lead#intro%hardbreaks]
      Hello.
    ADOC

    assert_equal :paragraph, paragraph.context
    assert_equal "intro", paragraph.attributes[:id]
    assert_equal "lead", paragraph.attributes[:role]
    assert_equal true, paragraph.attributes[:hardbreaks]
  end

  private

  def parse_first_block(source)
    AsciidoctorVaped.parse(source).blocks.first
  end
end
