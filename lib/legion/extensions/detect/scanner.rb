# frozen_string_literal: true

require 'socket'

module Legion
  module Extensions
    module Detect
      module Scanner
        class << self
          def scan
            env = gather_environment
            CATALOG.each_with_object([]) do |rule, results|
              matched_signals = rule[:signals].select { |s| signal_present?(s, env) }
              next if matched_signals.empty?

              results << {
                name:            rule[:name],
                extensions:      rule[:extensions],
                matched_signals: matched_signals.map { |s| "#{s[:type]}:#{s[:match]}" },
                installed:       rule[:extensions].to_h { |e| [e, gem_installed?(e)] }
              }
            end
          end

          def gather_environment
            {
              apps:          scan_applications,
              brew_formulas: scan_brew_formulas,
              brew_casks:    scan_brew_casks,
              env_vars:      ENV.keys,
              ports:         scan_ports,
              files:         nil
            }
          end

          def reset!
            @environment = nil
          end

          private

          def scan_applications
            Dir.glob('/Applications/*.app').map { |p| File.basename(p) }
          rescue StandardError
            []
          end

          def scan_brew_formulas
            `brew list --formula -1 2>/dev/null`.split("\n")
          rescue StandardError
            []
          end

          def scan_brew_casks
            `brew list --cask -1 2>/dev/null`.split("\n")
          rescue StandardError
            []
          end

          def scan_ports
            threads = SCAN_PORTS.map do |port|
              Thread.new(port) do |p|
                Socket.tcp('127.0.0.1', p, connect_timeout: 1) { true }
              rescue StandardError
                false
              end
            end

            SCAN_PORTS.zip(threads.map(&:value)).select { |_port, open| open }.map(&:first)
          end

          def signal_present?(signal, env)
            case signal[:type]
            when :app          then env[:apps].any? { |a| match_value?(a, signal[:match]) }
            when :brew_formula then env[:brew_formulas].any? { |f| match_value?(f, signal[:match]) }
            when :brew_cask    then env[:brew_casks].any? { |c| match_value?(c, signal[:match]) }
            when :env          then env[:env_vars].include?(signal[:match])
            when :port         then env[:ports].include?(signal[:match])
            when :file         then File.exist?(File.expand_path(signal[:match]))
            else false
            end
          end

          def match_value?(value, pattern)
            pattern.is_a?(Regexp) ? value.match?(pattern) : value == pattern
          end

          def gem_installed?(name)
            Gem::Specification.find_by_name(name)
            true
          rescue Gem::MissingSpecError
            false
          end
        end
      end
    end
  end
end
