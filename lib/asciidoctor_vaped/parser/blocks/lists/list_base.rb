# frozen_string_literal: true

require_relative "../../common/base_node"
require_relative "list_item"

module AsciidoctorVaped
  module Parser
    module Blocks
      class ListBase < BaseNode
        def parse(context)
          match = self.class.match_line(context.reader.peek)
          context.append parse_list(context, self.class, match[:depth])
        end

        def self.match_line(line)
          return unless (match = self::PATTERN.match(line.to_s))

          { match:, depth: marker_depth(match[:marker]) }
        end

        def self.marker_depth(marker)
          marker.length
        end

        def self.build_item(context, match)
          ListItem.build(context.reader.read.sub(match.regexp, ""))
        end

        def self.detect(line)
          [UnorderedList, OrderedList, DescriptionList].filter_map do |handler|
            match = handler.match_line(line)
            [handler, match] if match
          end.first
        end

        protected

        def parse_list(context, handler, depth, ancestors = [])
          list = AST::Element.new(handler::CONTEXT)
          last_item = nil

          while (detected = self.class.detect(context.reader.peek))
            current_handler, match = detected
            if current_handler == handler && match[:depth] == depth
              list << (last_item = handler.build_item(context, match[:match]))
            elsif ancestor?(ancestors, current_handler, match[:depth])
              break
            elsif last_item && (current_handler != handler || match[:depth] > depth)
              last_item << parse_list(context, current_handler, match[:depth], ancestors + [[handler, depth]])
            else
              break
            end
          end

          list
        end

        def ancestor?(ancestors, handler, depth)
          ancestors.any? { |ancestor, ancestor_depth| ancestor == handler && depth <= ancestor_depth }
        end
      end
    end
  end
end
