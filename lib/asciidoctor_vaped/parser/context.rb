# frozen_string_literal: true

module AsciidoctorVaped
  module Parser
    class Context
      attr_reader :document, :reader, :pending_attributes

      def initialize(document, reader, parent: nil)
        @document = document
        @reader = reader
        @parent = parent
        @sections = []
        @pending_attributes = {}
      end

      def nested(parent, reader = @reader)
        self.class.new(document, reader, parent:)
      end

      def append(node)
        node.attributes.merge!(consume_attributes)
        parent << node
      end

      def open_section(section)
        level = section.attributes.fetch(:level)
        @sections.pop while @sections.any? && @sections.last.attributes.fetch(:level) >= level
        parent << section
        @sections << section
      end

      def add_pending_attributes(attributes)
        @pending_attributes.merge!(attributes)
      end

      def pending_title=(title)
        @pending_attributes[:title] = title
      end

      private

      def consume_attributes
        @pending_attributes.tap { @pending_attributes = {} }
      end

      def parent
        @sections.last || @parent || document
      end
    end
  end
end
