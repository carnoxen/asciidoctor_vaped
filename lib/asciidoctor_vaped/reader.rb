# frozen_string_literal: true

module AsciidoctorVaped
  class Reader
    attr_reader :lineno

    def initialize(source)
      @lines = source.to_s.each_line(chomp: true).to_a
      @lineno = 0
    end

    def eof?
      lineno >= @lines.length
    end

    def peek
      @lines[lineno]
    end

    def read
      return if eof?

      @lines[lineno].tap { @lineno += 1 }
    end

    def skip_blank_lines
      read while peek&.strip == ""
    end

    def read_until_blank
      read_while { |line| line.strip != "" }
    end

    def read_delimited(delimiter)
      read
      lines = read_while { |line| line != delimiter }
      read if peek == delimiter
      lines
    end

    def read_while
      lines = []
      lines << read while peek && yield(peek)
      lines
    end
  end
end
