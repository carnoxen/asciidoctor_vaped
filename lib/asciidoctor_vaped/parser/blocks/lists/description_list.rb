# frozen_string_literal: true

require_relative "list_base"

module AsciidoctorVaped
  module Parser
    module Blocks
      class DescriptionList < ListBase
        CONTEXT = :dlist
        PATTERN = /\A(?<term>.+?)(?<marker>:{2,})(?:\s+(?<description>.*))?\z/

        def self.marker_depth(marker)
          marker.length - 1
        end

        def self.build_item(context, match)
          context.reader.read
          description = match[:description]
          if description.nil? || description.empty?
            description = context.reader.read_while do |line|
              !line.empty? && !ListBase.detect(line)
            end.join("\n")
          end

          AST::Element.new(:description_item, children: [
                             AST::Element.new(:term, children: Inline.parse(match[:term])),
                             AST::Element.new(:description, children: Inline.parse(description))
                           ])
        end
      end
    end
  end
end
