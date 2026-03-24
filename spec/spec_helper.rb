# frozen_string_literal: true

require 'bundler/setup'

require 'legion/json'
require 'legion/logging'
require 'legion/settings'
require 'legion/cache'
require 'legion/crypt'
require 'legion/data'
require 'legion/transport'

module Legion
  module Extensions
    module Helpers
      module Lex
        def self.included(base)
          base.instance_variable_set(:@lex_settings, {})
        end
      end
    end

    module Core; end

    module Actors
      class Once
        def initialize(**_opts); end

        def runner_class
          self.class
        end
      end

      class Every
        def initialize(**_opts); end

        def runner_class
          self.class
        end
      end
    end
  end
end

require 'legion/extensions/detect'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }

  config.before do
    Legion::Extensions::Detect::Scanner.reset!
  end
end
