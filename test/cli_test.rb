# frozen_string_literal: true

require "stringio"
require "tmpdir"
require "test_helper"

class CLITest < Minitest::Test
  def test_string_mode_writes_docbook_to_stdout
    out = StringIO.new
    status = AsciidoctorVaped::CLI.new(["-s", "hello *world*"], out:).run

    assert_equal 0, status
    assert_includes out.string, "<para>hello <emphasis role=\"strong\">world</emphasis></para>"
  end

  def test_file_mode_writes_default_html_file
    Dir.mktmpdir do |dir|
      input = File.join(dir, "demo.adoc")
      output = File.join(dir, "demo.html")
      File.write(input, "= Demo\n\nhello *world*")

      Dir.chdir(dir) do
        assert_equal 0, AsciidoctorVaped::CLI.new([input]).run
      end

      assert File.exist?(output)
      assert_includes File.read(output), "<strong>world</strong>"
    end
  end

  def test_file_mode_writes_docbook_for_docbook_extension
    Dir.mktmpdir do |dir|
      input = File.join(dir, "demo.adoc")
      output = File.join(dir, "result.dkb")
      File.write(input, "= Demo")

      assert_equal 0, AsciidoctorVaped::CLI.new([input, output]).run

      assert File.exist?(output)
      assert_includes File.read(output), "<article>"
    end
  end

  def test_file_mode_writes_html_for_html_extension
    Dir.mktmpdir do |dir|
      input = File.join(dir, "demo.adoc")
      output = File.join(dir, "result.html")
      File.write(input, "= Demo")

      assert_equal 0, AsciidoctorVaped::CLI.new([input, output]).run

      assert File.exist?(output)
      assert_includes File.read(output), "<!DOCTYPE html>"
    end
  end
end
