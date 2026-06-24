# frozen_string_literal: true

require_relative "asciidoctor_vaped/version"
require_relative "asciidoctor_vaped/error"
require_relative "asciidoctor_vaped/ast/document"
require_relative "asciidoctor_vaped/ast/node"
require_relative "asciidoctor_vaped/converter/docbook"
require_relative "asciidoctor_vaped/converter/html"
require_relative "asciidoctor_vaped/parser"
require_relative "asciidoctor_vaped/reader"

module AsciidoctorVaped
  def self.load(source, options = {})
    Parser.parse(source, attributes: normalize_options(options).fetch(:attributes, {}))
  end

  def self.load_file(filename, options = {})
    load(File.read(filename), options)
  end

  def self.convert(source, options = {})
    options = normalize_options(options)
    converter_for(options).new(options).convert(load(source, options))
  end

  def self.convert_file(filename, options = {})
    html = convert(File.read(filename), options)
    outfile = normalize_options(options)[:to_file]
    return html unless outfile

    File.write(outfile, html)
    nil
  end

  def self.parse(source, attributes: {})
    Parser.parse(source, attributes:)
  end

  def self.normalize_options(options)
    options.transform_keys(&:to_sym)
  end

  def self.converter_for(options)
    case options.fetch(:backend, :html).to_sym
    when :docbook, :dkb then Converter::DocBook
    else Converter::HTML
    end
  end

  private_class_method :normalize_options, :converter_for
end
