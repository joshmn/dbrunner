# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "dbrunner"
  spec.version = "0.1.0"
  spec.authors = ["Josh Brody"]
  spec.summary = "rails dbrunner — run SQL like rails runner runs Ruby"
  spec.description = "Adds a `rails dbrunner` command that executes SQL against your database. Accepts inline SQL, .sql files, or stdin. Outputs as table, CSV, or JSON."
  spec.homepage = "https://github.com/joshmn/dbrunner"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.files = Dir["lib/**/*", "LICENSE.txt", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "railties", ">= 6.1"
  spec.add_dependency "activerecord", ">= 6.1"
end
