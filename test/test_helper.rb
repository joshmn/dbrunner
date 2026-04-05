# frozen_string_literal: true

require "minitest/autorun"
require "shellwords"
require "json"
require "csv"
require "fileutils"

DUMMY_APP_PATH = File.expand_path("dummy", __dir__)
GEM_ROOT = File.expand_path("..", __dir__)

module DbrunnerTestHelper
  private

  def dbrunner(*args, allow_failure: false)
    rails_bin = File.join(DUMMY_APP_PATH, "bin/rails")
    cmd = ["bundle", "exec", "ruby", rails_bin, "dbrunner", *args].shelljoin
    output = `cd #{GEM_ROOT} && RAILS_ENV=test #{cmd} 2>&1`
    unless allow_failure
      raise "Command failed (exit #{$?.exitstatus}):\n#{output}" unless $?.success?
    end
    output
  end

  def rails(*args, allow_failure: false)
    rails_bin = File.join(DUMMY_APP_PATH, "bin/rails")
    cmd = ["bundle", "exec", "ruby", rails_bin, *args].shelljoin
    output = `cd #{GEM_ROOT} && RAILS_ENV=test #{cmd} 2>&1`
    unless allow_failure
      raise "Command failed (exit #{$?.exitstatus}):\n#{output}" unless $?.success?
    end
    output
  end

  def setup_test_table
    rails("runner", <<~RUBY)
      ActiveRecord::Schema.define do
        create_table(:dbrunner_test, force: true) do |t|
          t.string :name
          t.integer :age
        end
      end
      ActiveRecord::Base.connection.execute("INSERT INTO dbrunner_test (name, age) VALUES ('alice', 30), ('bob', 25), ('carol', NULL)")
    RUBY
  end
end
