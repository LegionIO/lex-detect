# frozen_string_literal: true

require 'legion/extensions/detect/version'
require 'legion/extensions/detect/catalog'
require 'legion/extensions/detect/scanner'
require 'legion/extensions/detect/installer'
require_relative 'detect/runners/task_observer'

module Legion
  module Extensions
    module Detect
      extend Legion::Extensions::Core if Legion::Extensions.const_defined?(:Core)

      class << self
        def data_required?
          false
        end

        def remote_invocable?
          false
        end

        def scan
          Scanner.scan
        end

        def missing
          results = scan
          results.each_with_object([]) do |detection, gems|
            detection[:installed].each do |gem_name, installed|
              gems << gem_name unless installed || gems.include?(gem_name)
            end
          end
        end

        def install_missing!(dry_run: false)
          Installer.install(missing, dry_run: dry_run)
        end

        def catalog
          CATALOG
        end
      end

      require_relative 'detect/actors/full_scan' if defined?(Legion::Extensions::Actors::Once)
      require_relative 'detect/actors/delta_scan' if defined?(Legion::Extensions::Actors::Every)

      if defined?(Legion::Data::Local)
        Legion::Data::Local.register_migrations(
          name: :detect,
          path: File.join(__dir__, 'detect', 'local_migrations')
        )
      end
    end
  end
end
