# frozen_string_literal: true

module AsciidoctorVaped
  module Callouts
    Mark = Data.define(:number, :position)
    Extraction = Data.define(:source, :marks)

    MARK = /(?<!\\)<(?<number>\d+|\.)>/

    module_function

    def extract(source)
      marks = []
      automatic_number = 0
      removed_length = 0
      clean_source = source.gsub(/\\(?=<(?:\d+|\.)>)|#{MARK}/) do |token|
        if token == "\\"
          removed_length += 1
        else
          number = Regexp.last_match[:number]
          number = (automatic_number += 1).to_s if number == "."
          marks << Mark.new(number:, position: Regexp.last_match.begin(0) - removed_length)
          removed_length += token.length
        end
        ""
      end

      Extraction.new(source: clean_source, marks:)
    end

    def restore_html(html, marks, &marker)
      marks = marks.group_by(&:position)
      output = +""
      position = 0
      index = 0

      while index < html.length
        append_marks(output, marks.delete(position), marker)
        token = html[index..]
        if (match = token.match(/\A<[^>]*>/))
          consumed = match[0]
        elsif (match = token.match(/\A&(?:#\d+|#x[\da-f]+|\w+);/i))
          consumed = match[0]
          position += 1
        else
          consumed = token[0]
          position += 1
        end
        output << consumed
        index += consumed.length
      end
      append_marks(output, marks.delete(position), marker)
      output
    end

    def append_marks(output, marks, marker)
      output << marks.map { |mark| marker.call(mark) }.join(" ") if marks
    end
    private_class_method :append_marks
  end
end
