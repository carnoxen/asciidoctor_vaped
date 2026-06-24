# frozen_string_literal: true

module AsciidoctorVaped
  module Parser
    class Context
      attr_reader :document, :reader

      def initialize(document, reader)
        @document = document
        @reader = reader
        @sections = []
        @pending_attributes = {}
      end

      def append(block)
        block.attributes.merge!(consume_attributes)
        parent << block
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
        @sections.last || document
      end
    end
  end
end
