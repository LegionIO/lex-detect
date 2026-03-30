# frozen_string_literal: true

module Legion
  module Extensions
    module Detect
      module Actor
        class FullScan < Legion::Extensions::Actors::Once
          def runner_class
            self.class
          end

          def delay
            2.0
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
            results = Scanner.scan
            persist_results(results)
            write_traces(results)
            transition_catalog
            results
          end

          private

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
          rescue StandardError => e
            Legion::Logging.debug { "FullScan persist failed: #{e.message}" } if defined?(Legion::Logging) # rubocop:disable Legion/HelperMigration/DirectLogging
          end

          def write_traces(results)
            return unless defined?(Legion::Extensions::Agentic::Memory)

            results.each do |result|
              Legion::Extensions::Agentic::Memory::Trace.write(
                source:     'lex-detect',
                category:   'environment',
                content:    "Detected #{result[:name]}: #{result[:matched_signals].join(', ')}",
                confidence: 0.9
              )
            end
          rescue StandardError => e
            Legion::Logging.debug { "FullScan trace write failed: #{e.message}" } if defined?(Legion::Logging) # rubocop:disable Legion/HelperMigration/DirectLogging
          end

          def transition_catalog
            return unless defined?(Legion::Extensions::Catalog)

            Legion::Extensions::Catalog.transition('lex-detect', :running)
          rescue StandardError => _e
            nil
          end
        end
      end
    end
  end
end
