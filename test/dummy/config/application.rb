# frozen_string_literal: true

require_relative "boot"
require "rails/all"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.eager_load = false
    config.secret_key_base = "test_secret_key_base_for_dbrunner"
    config.root = File.expand_path("..", __dir__)
  end
end
