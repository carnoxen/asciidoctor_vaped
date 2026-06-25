# frozen_string_literal: true

require_relative "../parser/inline"

module AsciidoctorVaped
  module Converter
    class BaseConverter
      def initialize(options = {})
        @options = options
      end

      def convert(_document)
        raise NotImplementedError, "#{self.class} must implement #convert"
      end

      private

      def escape(value)
        value.to_s
          .gsub("&", "&amp;")
          .gsub("<", "&lt;")
          .gsub(">", "&gt;")
          .gsub('"', "&quot;")
      end

      def escape_attr(value)
        escape(value).gsub('"', "&quot;")
      end
    end
  end
end
