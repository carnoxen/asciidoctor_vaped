# frozen_string_literal: true

require_relative "node"

module AsciidoctorVaped
  module AST
    class Element < Node
      attr_reader :context, :attributes

      def initialize(context, attributes: {}, children: [])
        @context = context
        @attributes = attributes
        super(children:)
      end
    end
  end
end
