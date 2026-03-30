# frozen_string_literal: true

module Legion
  module Extensions
    module Detect
      module Runners
        module TaskObserver
          extend self

          def observe(tasks: nil, since: nil, **)
            return observe_db(since: since) if tasks.nil?

            return { success: true, alerts: [] } unless tasks.is_a?(Array)

            alerts = generate_alerts(tasks)
            check_and_publish_failure_patterns(tasks)
            { success: true, alerts: alerts, task_count: tasks.size }
          rescue StandardError => e
            { success: false, reason: :error, message: e.message }
          end

          private

          def observe_db(since: nil)
            return { alerts: [], observed: 0 } unless defined?(Legion::Data)

            since ||= Time.now - 60
            db_tasks = Legion::Data.connection[:tasks]
                                   .where { created > since }
                                   .all

            alerts = db_tasks.filter_map { |task| evaluate_rules(task) }

            publish_alerts(alerts) if alerts.any?
            record_observations(db_tasks, alerts)

            { alerts: alerts, observed: db_tasks.size }
          rescue StandardError => e
            { alerts: [], observed: 0, error: e.message }
          end

          def evaluate_rules(task)
            check_timeout_risk(task) ||
              check_repeated_failure(task) ||
              check_cost_spike(task)
          end

          def check_timeout_risk(task, expected_duration: 120)
            return nil unless task[:status] == 'running' && task[:created]

            elapsed = Time.now - task[:created]
            return nil unless elapsed > (expected_duration * 2)

            {
              rule:        'timeout_risk',
              runner:      task[:runner_class],
              task_id:     task[:id],
              severity:    'warn',
              detail:      "Running for #{elapsed.round}s (expected #{expected_duration}s)",
              observed_at: Time.now.utc
            }
          end

          def check_repeated_failure(task)
            return nil unless defined?(Legion::Data) && task[:runner_class]

            count = Legion::Data.connection[:tasks]
                                .where(runner_class: task[:runner_class], status: 'failed')
                                .where { created > Time.now - 600 }
                                .count
            return nil unless count >= 3

            {
              rule:        'repeated_failure',
              runner:      task[:runner_class],
              task_id:     task[:id],
              severity:    'critical',
              detail:      "#{count} failures in last 10 minutes",
              observed_at: Time.now.utc
            }
          rescue StandardError => _e
            nil
          end

          def check_cost_spike(_task)
            nil
          end

          def publish_alerts(alerts)
            return unless Legion.const_defined?(:Transport, false)

            alerts.each do |alert|
              Legion::Transport::Messages::Dynamic.new(
                function: 'observer_alert',
                payload:  alert
              ).publish
            end
          rescue StandardError => _e
            nil
          end

          def record_observations(db_tasks, alerts)
            return unless defined?(Legion::Data::Local)

            db_tasks.each do |task|
              alert = alerts.find { |a| a[:task_id] == task[:id] }
              Legion::Data::Local.connection[:observer_events].insert( # rubocop:disable Legion/HelperMigration/DirectData
                task_id:     task[:id],
                runner:      task[:runner_class],
                rule:        alert&.dig(:rule),
                severity:    alert&.dig(:severity),
                duration:    task[:created] ? (Time.now - task[:created]).round(2) : nil,
                token_cost:  nil,
                observed_at: Time.now.utc
              )
            end
          rescue StandardError => _e
            nil
          end

          def generate_alerts(tasks)
            failed = tasks.select { |t| t[:status] == 'failed' }
            return [] if failed.empty?

            failed.group_by { |t| t[:runner_class] }.filter_map do |runner_class, failures|
              next unless failures.size >= 3

              { runner_class: runner_class, failure_count: failures.size, level: :warning }
            end
          end

          def check_and_publish_failure_patterns(tasks)
            return unless defined?(Legion::Data) && Legion.const_defined?(:Transport, false)

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
          rescue StandardError => _e
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
          rescue StandardError => _e
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
