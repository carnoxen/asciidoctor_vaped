# frozen_string_literal: true

require_relative "../asciidoctor_vaped"

module AsciidoctorVaped
  class CLI
    def initialize(argv, out: $stdout, err: $stderr)
      @argv = argv.dup
      @out = out
      @err = err
    end

    def run
      return string_mode if @argv.first == "-s"
      return usage(1) if @argv.empty?

      file_mode
    rescue Errno::ENOENT => error
      @err.puts error.message
      1
    end

    private

    def string_mode
      @argv.shift
      source = @argv.shift
      return usage(1) unless source

      @out.puts AsciidoctorVaped.convert(source, backend: :docbook, header_footer: false)
      0
    end

    def file_mode
      input = @argv.shift
      output = @argv.shift || default_output(input)
      File.write(output, AsciidoctorVaped.convert(File.read(input), backend: :docbook))
      0
    end

    def default_output(input)
      "#{File.basename(input, File.extname(input))}.dkb"
    end

    def usage(status)
      @err.puts "Usage:"
      @err.puts "  asciidoctor_vaped FILE [OUTPUT.dkb]"
      @err.puts "  asciidoctor_vaped -s STRING"
      status
    end
  end
end
