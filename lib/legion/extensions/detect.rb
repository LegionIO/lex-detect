# frozen_string_literal: true

require 'legion/extensions/detect/version'
require 'legion/extensions/detect/catalog'
require 'legion/extensions/detect/scanner'
require 'legion/extensions/detect/installer'

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
    end
  end
end
