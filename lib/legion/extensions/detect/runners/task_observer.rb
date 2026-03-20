# frozen_string_literal: true

module Legion
  module Extensions
    module Detect
      module Runners
        module TaskObserver
          extend self

          def observe(tasks:, **)
            return { success: true, alerts: [] } unless tasks.is_a?(Array)

            alerts = generate_alerts(tasks)
            check_and_publish_failure_patterns(tasks)
            { success: true, alerts: alerts, task_count: tasks.size }
          rescue StandardError => e
            { success: false, reason: :error, message: e.message }
          end

          private

          def generate_alerts(tasks)
            failed = tasks.select { |t| t[:status] == 'failed' }
            return [] if failed.empty?

            failed.group_by { |t| t[:runner_class] }.filter_map do |runner_class, failures|
              next unless failures.size >= 3

              { runner_class: runner_class, failure_count: failures.size, level: :warning }
            end
          end

          def check_and_publish_failure_patterns(tasks)
            return unless defined?(Legion::Data) && defined?(Legion::Transport)

            runner_failures = tasks.select { |t| t[:status] == 'failed' }
                                   .group_by { |t| t[:runner_class] }

            runner_failures.each do |runner_class, failures|
              next unless failures.size >= 3

              gem_name = extract_gem_name(runner_class)
              backtraces = failures.filter_map { |f| f[:error_backtrace] }.first(5)
              error_class = failures.first[:error_class] || 'StandardError'

              pattern = build_failure_pattern(gem_name, runner_class, error_class, backtraces, failures.size)
              publish_failure_pattern(pattern)
            end
          rescue StandardError
            nil
          end

          def build_failure_pattern(gem_name, runner_class, error_class, backtraces, count)
            {
              gem_name:       gem_name,
              runner_class:   runner_class,
              error_class:    error_class,
              backtraces:     backtraces,
              failure_count:  count,
              window_minutes: 60
            }
          end

          def publish_failure_pattern(pattern)
            return unless defined?(Legion::Transport::Messages::Dynamic)

            Legion::Transport::Messages::Dynamic.new(
              function: 'auto_fix',
              payload:  pattern
            ).publish
          rescue StandardError
            nil
          end

          def extract_gem_name(runner_class)
            return nil unless runner_class

            parts = runner_class.to_s.split('::')
            ext_idx = parts.index('Extensions')
            return nil unless ext_idx && parts[ext_idx + 1]

            "lex-#{parts[ext_idx + 1].gsub(/([a-z])([A-Z])/, '\1_\2').downcase}"
          end
        end
      end
    end
  end
end
