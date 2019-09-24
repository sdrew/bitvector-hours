require "bundler/setup"
require "active_support/testing/time_helpers"

if ENV['CODECOV_TOKEN'].present?
  require 'simplecov'
  require 'codecov'

  SimpleCov.formatter = SimpleCov::Formatter::Codecov
  SimpleCov.profiles.define 'gem' do
    add_filter '/spec/'

    add_group 'Source', 'lib'
  end

  SimpleCov.start 'gem'
end

require "bitvector/hours"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include ActiveSupport::Testing::TimeHelpers
end
