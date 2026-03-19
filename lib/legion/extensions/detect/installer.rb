# frozen_string_literal: true

module Legion
  module Extensions
    module Detect
      module Installer
        class << self
          def install(gem_names, dry_run: false)
            return { installed: gem_names, failed: [] } if dry_run

            installed = []
            failed = []

            gem_names.each do |name|
              Gem.install(name)
              installed << name
            rescue StandardError => e
              failed << { name: name, error: e.message }
            end

            { installed: installed, failed: failed }
          end
        end
      end
    end
  end
end
