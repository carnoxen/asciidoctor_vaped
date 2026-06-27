# frozen_string_literal: true

require_relative "../../common/base_node"
require "strscan"

module AsciidoctorVaped
  module Parser
    module Blocks
      class ElementAttributes < BaseNode
        PATTERN = /\A\[(.+)\]\z/

        def parse(context)
          context.add_pending_attributes parse_attributes(context.reader.read.match(PATTERN)[1])
        end

        private

        def parse_attributes(value)
          split_attributes(value).each_with_object({ positional: [] }) do |part, attributes|
            parse_attribute(part, attributes)
          end.then { |attributes| normalize_attributes(attributes) }
        end

        def split_attributes(value)
          value.scan(/(?:"[^"]*"|'[^']*'|[^,])+/).map(&:strip).reject(&:empty?)
        end

        def parse_attribute(part, attributes)
          name, value = part.split("=", 2)
          return attributes[:positional] << unquote(part) unless value

          assign_named_attribute(attributes, name.strip, unquote(value.strip))
        end

        def assign_named_attribute(attributes, name, value)
          key = normalize_name(name)
          return parse_options(value, attributes) if key == :opts

          attributes[key] = value
        end

        def normalize_attributes(attributes)
          positional = attributes.delete(:positional)
          parse_shorthand(positional.shift, attributes)
          attributes[:language] = positional.shift if attributes[:style] == :source && positional.any?
          positional.each { |part| attributes[normalize_name(part)] = true }
          attributes
        end

        def parse_shorthand(value, attributes)
          return unless value

          scanner = StringScanner.new(value)
          attributes[:style] = scanner.scan(/[^\s#.%]+/)&.to_sym
          parse_shorthand_marks(scanner.rest, attributes)
        end

        def parse_shorthand_marks(value, attributes)
          value.scan(/([#.%])([^#.%]+)/).each do |mark, name|
            case mark
            when "#" then attributes[:id] = name
            when "." then append_role(attributes, name)
            when "%" then attributes[normalize_name(name)] = true
            end
          end
        end

        def append_role(attributes, name)
          attributes[:role] = [attributes[:role], name].compact.join(" ")
        end

        def parse_options(value, attributes)
          value.split(",").map(&:strip).each { |option| attributes[normalize_name(option)] = true }
        end

        def normalize_name(value)
          value.tr("-", "_").to_sym
        end

        def unquote(value)
          value.sub(/\A(["'])(.*)\1\z/, "\\2")
        end
      end
    end
  end
end
