# frozen_string_literal: true

require "test_helper"

class ListsTest < Minitest::Test
  def test_parse_builds_unordered_and_ordered_lists
    document = AsciidoctorVaped.parse <<~ADOC
      * Edgar Allan Poe
      * Sheri S. Tepper

      . Protons
      . Electrons
    ADOC

    unordered, ordered = document.children

    assert_equal :ulist, unordered.context
    assert_equal :olist, ordered.context
    assert_equal ["Edgar Allan Poe", "Sheri S. Tepper"], unordered.children.map(&:text)
    assert_equal %w[Protons Electrons], ordered.children.map(&:text)
  end

  def test_parse_chains_list_items_to_inline_nodes
    document = AsciidoctorVaped.parse <<~ADOC
      * Use *strong* text
    ADOC

    item = document.children.first.children.first

    assert_equal :list_item, item.context
    assert_equal ["Use ", :strong, " text"],
                 item.children.map { |child| child.is_a?(String) ? child : child.context }
  end

  def test_parse_builds_nested_unordered_and_ordered_lists
    document = AsciidoctorVaped.parse <<~ADOC
      * Parent
      ** Child
      *** Grandchild
      ** Sibling child
      * Sibling parent

      . First
      .. Second
      ... Third
    ADOC

    unordered, ordered = document.children
    child_list = unordered.children.first.children.last

    assert_equal :ulist, child_list.context
    assert_equal ["Child", "Sibling child"], child_list.children.map(&:text)
    assert_equal "Grandchild", child_list.children.first.children.last.children.first.text
    assert_equal "Sibling parent", unordered.children.last.text
    assert_equal "Third", ordered.children.first.children.last.children.first.children.last.children.first.text
  end

  def test_parse_builds_nested_description_lists
    document = AsciidoctorVaped.parse <<~ADOC
      Operating system:: Linux
      Distribution::: Fedora
      Desktop:::: GNOME
      Language:: Ruby
    ADOC

    list = document.children.first
    nested = list.children.first.children.last

    assert_equal :dlist, list.context
    assert_equal "Operating systemLinux", list.children.first.text
    assert_equal :dlist, nested.context
    assert_equal "DistributionFedora", nested.children.first.text
    assert_equal "GNOME", nested.children.first.children.last.children.first.children[1].text
  end

  def test_parse_description_on_following_line
    item = AsciidoctorVaped.parse(<<~ADOC).children.first.children.first
      Question?::
      Answer with *strong* text.
    ADOC

    assert_equal "Question?Answer with strong text.", item.text
    assert_equal :strong, item.children[1].children[1].context
  end

  def test_parse_builds_mixed_nested_lists
    list = AsciidoctorVaped.parse(<<~ADOC).children.first
      * Bullet
      . Number
      Term:: Description
      * Next bullet
    ADOC

    ordered = list.children.first.children.last
    description = ordered.children.first.children.last

    assert_equal :olist, ordered.context
    assert_equal :dlist, description.context
    assert_equal "Next bullet", list.children.last.text
  end

end
