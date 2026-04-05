# frozen_string_literal: true

source "https://rubygems.org"

gemspec

if ENV["RAILS_VERSION"]
  gem "rails", "~> #{ENV["RAILS_VERSION"]}.0"
else
  gem "rails"
end

if ENV["RAILS_VERSION"] && Gem::Version.new(ENV["RAILS_VERSION"]) < Gem::Version.new("7.2")
  gem "sqlite3", "~> 1.4"
else
  gem "sqlite3"
end

gem "csv"
