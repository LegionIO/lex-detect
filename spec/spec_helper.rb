# frozen_string_literal: true

require 'bundler/setup'
require 'legion/extensions/detect'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }

  config.before do
    Legion::Extensions::Detect::Scanner.reset!
  end
end
