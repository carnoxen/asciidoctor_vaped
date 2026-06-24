# frozen_string_literal: true

require_relative "lib/asciidoctor_vaped/version"

Gem::Specification.new do |spec|
  spec.name = "asciidoctor_vaped"
  spec.version = AsciidoctorVaped::VERSION
  spec.authors = ["Kaben"]
  spec.email = ["carnoxen@gmail.com"]

  spec.summary = "TODO: Write a short summary, because RubyGems requires one."
  spec.description = "TODO: Write a longer description or delete this line."
  spec.homepage = "TODO: Put your gem's website or public repo URL here."
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"
  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."

  # Uncomment the line below to require MFA for gem pushes.
  # This helps protect your gem from supply chain attacks by ensuring
  # no one can publish a new version without multi-factor authentication.
  # See: https://guides.rubygems.org/mfa-requirement-opt-in/
  # spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(__dir__) do
    Dir["exe/*", "lib/**/*.rb", "sig/**/*.rbs", "LICENSE.txt", "README.md"]
  end
  spec.bindir = "exe"
  spec.executables = ["asciidoctor_vaped"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest", "~> 5.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://guides.rubygems.org/make-your-own-gem/
end
