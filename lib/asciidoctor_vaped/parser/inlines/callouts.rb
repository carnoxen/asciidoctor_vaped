# frozen_string_literal: true

module AsciidoctorVaped
  module Callouts
    Mark = Data.define(:number, :position)
    Extraction = Data.define(:source, :marks)

    MARK = /(?<!\\)(?:<(?<number>\d+|\.)>|<!--(?<xml_number>\d+|\.)-->)/
    SUFFIX = /(?:\s*(?:(?:\/\/|#|;;)\s*)?#{MARK})+\s*\z/

    module_function

    def extract(source)
      marks = []
      automatic_number = 0
      clean_source = +""

      source.each_line do |line|
        newline = line.end_with?("\n") ? "\n" : ""
        body = newline.empty? ? line : line.delete_suffix("\n")
        match = SUFFIX.match(body)
        unless match
          clean_source << line.gsub(/\\(?=<(?:\d+|\.)>)/, "")
          next
        end

        clean_body = body[0...match.begin(0)].rstrip
        position = clean_source.length + clean_body.length
        match[0].scan(MARK) do |number, xml_number|
          number = number || xml_number
          number = (automatic_number += 1).to_s if number == "."
          marks << Mark.new(number:, position:)
        end
        clean_source << clean_body << newline
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
