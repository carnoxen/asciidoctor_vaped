# frozen_string_literal: true

require_relative "lib/asciidoctor_vaped/version"

Gem::Specification.new do |spec|
  spec.name = "asciidoctor_vaped"
  spec.version = AsciidoctorVaped::VERSION
  spec.authors = ["Kaben"]
  spec.email = ["carnoxen@gmail.com"]

  spec.summary = "Reshaped Asciidoctor inspired by the original."
  spec.description = "A reshaped version of Asciidoctor with a modern twist."
  spec.homepage = "https://github.com/carnoxen/asciidoctor_vaped"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/carnoxen/asciidoctor_vaped.git"

  # Uncomment the line below to require MFA for gem pushes.
  # This helps protect your gem from supply chain attacks by ensuring
  # no one can publish a new version without multi-factor authentication.
  # See: https://guides.rubygems.org/mfa-requirement-opt-in/
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(__dir__) do
    Dir["exe/*", "lib/**/*", "sig/**/*.rbs", "LICENSE.txt", "README.md"]
  end
  spec.bindir = "exe"
  spec.executables = ["asciidoctor_vaped"]
  spec.require_paths = ["lib"]

  # For more information and examples about making a new gem, check out our
  # guide at: https://guides.rubygems.org/make-your-own-gem/
end
