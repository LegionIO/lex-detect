# frozen_string_literal: true

module Legion
  module Extensions
    module Detect
      module Actors
        class FullScan < Legion::Extensions::Actors::Once
          def delay
            2.0
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
                          Legion::Data::Local.connected?

            model = Legion::Data::Local.model(:detect_results)
            model.where.delete
            results.each do |result|
              model.insert(
                name:            result[:name],
                extensions:      Legion::JSON.dump(result[:extensions]),
                matched_signals: Legion::JSON.dump(result[:matched_signals]),
                installed:       Legion::JSON.dump(result[:installed]),
                scanned_at:      Time.now,
                created_at:      Time.now,
                updated_at:      Time.now
              )
            end
          rescue StandardError => e
            Legion::Logging.debug { "FullScan persist failed: #{e.message}" } if defined?(Legion::Logging)
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
            Legion::Logging.debug { "FullScan trace write failed: #{e.message}" } if defined?(Legion::Logging)
          end

          def transition_catalog
            return unless defined?(Legion::Extensions::Catalog)

            Legion::Extensions::Catalog.transition('lex-detect', :running)
          rescue StandardError
            nil
          end
        end
      end
    end
  end
end
