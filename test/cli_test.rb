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

  def test_file_mode_writes_default_docbook_file
    Dir.mktmpdir do |dir|
      input = File.join(dir, "demo.adoc")
      output = File.join(dir, "demo.dkb")
      File.write(input, "= Demo\n\nhello *world*")

      Dir.chdir(dir) do
        assert_equal 0, AsciidoctorVaped::CLI.new([input]).run
      end

      assert File.exist?(output)
      assert_includes File.read(output), "<title>Demo</title>"
    end
  end

  def test_file_mode_writes_explicit_output
    Dir.mktmpdir do |dir|
      input = File.join(dir, "demo.adoc")
      output = File.join(dir, "result.dkb")
      File.write(input, "= Demo")

      assert_equal 0, AsciidoctorVaped::CLI.new([input, output]).run

      assert File.exist?(output)
      assert_includes File.read(output), "<article>"
    end
  end
end
