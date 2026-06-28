# frozen_string_literal: true

require_relative "../common/base_node"

module AsciidoctorVaped
  module Parser
    module Blocks
      class Media < BaseNode
        PATTERN = /\A(image|audio|video)::([^\[]+)\[(.*)\]\z/
        POSITIONAL_ATTRIBUTES = {
          image: %i[alt width height],
          audio: [],
          video: %i[poster width height]
        }.freeze
        VIDEO_PROVIDERS = %w[youtube vimeo].freeze

        def parse(context)
          type, target, attribute_list = context.reader.read.match(PATTERN).captures
          type = type.to_sym
          attributes = { target: target.strip }
          parse_attributes(type, attribute_list, attributes)
          context.append AST::Element.new(type, attributes:)
        end

        private

        def parse_attributes(type, value, attributes)
          positional = split_attributes(value).reject do |attribute|
            parse_named_attribute(attribute, attributes)
          end
          parse_positional_attributes(type, positional, attributes)
        end

        def split_attributes(value)
          value.scan(/(?:"[^"]*"|'[^']*'|[^,])+/).map(&:strip).reject(&:empty?)
        end

        def parse_named_attribute(attribute, attributes)
          name, value = attribute.split("=", 2)
          return false unless value

          name = name.strip.tr("-", "_").to_sym
          value = value.strip.sub(/\A(["'])(.*)\1\z/, "\\2")
          if %i[opts options].include?(name)
            value.split(",").each { |option| attributes[option.strip.tr("-", "_").to_sym] = true }
          else
            attributes[name] = value
          end
          true
        end

        def parse_positional_attributes(type, positional, attributes)
          if type == :video && VIDEO_PROVIDERS.include?(positional.first)
            attributes[:provider] = positional.shift
          end
          POSITIONAL_ATTRIBUTES.fetch(type).zip(positional).each do |name, value|
            attributes[name] = value unless value.nil? || value.empty?
          end
        end
      end
    end
  end
end
