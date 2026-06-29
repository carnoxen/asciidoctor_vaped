# frozen_string_literal: true

require_relative "common/base_node"
require_relative "inlines/callouts"
require_relative "inlines/link"
require_relative "inlines/url"
require_relative "inlines/strong"
require_relative "inlines/emphasis"
require_relative "inlines/monospace"

module AsciidoctorVaped
  module Parser
    module Inline
      PATTERNS = [
        Inlines::Link,
        Inlines::Url,
        Inlines::Strong,
        Inlines::Emphasis,
        Inlines::Monospace
      ].freeze

      module_function

      def parse(text)
        parse_until_done(text.to_s)
      end

      def parse_until_done(text)
        nodes = []

        until text.empty?
          token = next_token(text)
          return nodes << text unless token

          start, finish, pattern = token
          nodes << text[0...start] if start.positive?
          nodes << pattern.node(text[start...finish])
          text = text[finish..] || ""
        end

        nodes
      end

      def next_token(text)
        PATTERNS.each_with_index.filter_map do |pattern, priority|
          match = pattern.match(text)
          [match.begin(0), priority, match.end(0), pattern] if match
        end.min_by { |start, priority, _finish, _pattern| [start, priority] }&.then do |start, _priority, finish, pattern|
          [start, finish, pattern]
        end
      end

      def container(context, text, attributes = {})
        AST::Element.new(context, attributes:, children: parse(text))
      end
    end
  end
end
