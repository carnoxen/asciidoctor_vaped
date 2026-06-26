# frozen_string_literal: true

require_relative "node"

module AsciidoctorVaped
  module AST
    class Document < Node
      attr_accessor :doctitle
      attr_reader :attributes

      def initialize(source, attributes: {})
        @attributes = attributes.dup
        @source = source
        super()
      end

      def context
        :document
      end

      def source
        @source.dup
      end

      def register_attribute(name, value)
        attributes[name.to_s] = value
      end

      def to_h
        super.merge(doctitle:)
      end
    end
  end
end
