# frozen_string_literal: true

module Legion
  module Extensions
    module Detect
      module Actor
        class DeltaScan < Legion::Extensions::Actors::Every # rubocop:disable Legion/Extension/EveryActorRequiresTime
          def runner_class
            self.class
          end

          def time
            settings_interval || 300
          end

          def run_now?
            false
          end

          def use_runner?
            false
          end

          def check_subtask?
            false
          end

          def generate_task?
            false
          end

          def action(**_opts)
            current = Scanner.scan
            previous = last_scan_results
            deltas = compute_deltas(current, previous)

            persist_results(current) unless deltas[:added].empty? && deltas[:removed].empty?
            write_delta_traces(deltas) unless deltas[:added].empty? && deltas[:removed].empty?
            deltas
          end

          private

          def settings_interval
            return nil unless defined?(Legion::Settings)

            Legion::Settings.dig(:extensions, :'lex-detect', :delta_interval)
          rescue StandardError => _e
            nil
          end

          def last_scan_results
            return [] unless defined?(Legion::Data::Local) &&
                             Legion::Data::Local.respond_to?(:connected?) &&
                             Legion::Data::Local.connected? # rubocop:disable Legion/HelperMigration/DirectData

            Legion::Data::Local.model(:detect_results).all.map do |row| # rubocop:disable Legion/HelperMigration/DirectData
              {
                name:            row[:name],
                extensions:      Legion::JSON.load(row[:extensions]), # rubocop:disable Legion/HelperMigration/DirectJson
                matched_signals: Legion::JSON.load(row[:matched_signals]) # rubocop:disable Legion/HelperMigration/DirectJson
              }
            end
          rescue StandardError => _e
            []
          end

          def compute_deltas(current, previous)
            prev_names = previous.to_set { |r| r[:name] }
            curr_names = current.to_set { |r| r[:name] }

            added = current.reject { |r| prev_names.include?(r[:name]) }
            removed = previous.reject { |r| curr_names.include?(r[:name]) }
            { added: added, removed: removed }
          end

          def persist_results(results)
            return unless defined?(Legion::Data::Local) &&
                          Legion::Data::Local.respond_to?(:connected?) &&
                          Legion::Data::Local.connected? # rubocop:disable Legion/HelperMigration/DirectData

            model = Legion::Data::Local.model(:detect_results) # rubocop:disable Legion/HelperMigration/DirectData
            model.where.delete
            results.each do |result|
              model.insert(
                name:            result[:name],
                extensions:      Legion::JSON.dump(result[:extensions]), # rubocop:disable Legion/HelperMigration/DirectJson
                matched_signals: Legion::JSON.dump(result[:matched_signals]), # rubocop:disable Legion/HelperMigration/DirectJson
                installed:       Legion::JSON.dump(result[:installed]), # rubocop:disable Legion/HelperMigration/DirectJson
                scanned_at:      Time.now,
                created_at:      Time.now,
                updated_at:      Time.now
              )
            end
          rescue StandardError => _e
            nil
          end

          def write_delta_traces(deltas)
            return unless defined?(Legion::Extensions::Agentic::Memory)

            deltas[:added]&.each do |r|
              Legion::Extensions::Agentic::Memory::Trace.write(
                source: 'lex-detect', category: 'environment',
                content: "New detection: #{r[:name]}", confidence: 0.8
              )
            end
          rescue StandardError => _e
            nil
          end
        end
      end
    end
  end
end
