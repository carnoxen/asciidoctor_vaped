# frozen_string_literal: true

require_relative "list_base"

module AsciidoctorVaped
  module Parser
    module Blocks
      class OrderedList < ListBase
        CONTEXT = :olist
        PATTERN = /\A(?<marker>\.+)\s+/
      end
    end
  end
end
