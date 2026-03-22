# frozen_string_literal: true

require 'json'

module Legion
  module Extensions
    module Detect
      module Formatters
        module Sarif
          SCHEMA = 'https://json.schemastore.org/sarif-2.1.0.json'
          SARIF_VERSION = '2.1.0'

          SEVERITY_MAP = {
            missing:   'warning',
            installed: 'note'
          }.freeze

          module_function

          def format(detections)
            rules   = build_rules(detections)
            results = build_results(detections)

            {
              '$schema' => SCHEMA,
              'version' => SARIF_VERSION,
              'runs'    => [{
                'tool'    => {
                  'driver' => {
                    'name'           => 'legion-detect',
                    'version'        => VERSION,
                    'informationUri' => 'https://github.com/LegionIO/lex-detect',
                    'rules'          => rules
                  }
                },
                'results' => results
              }]
            }
          end

          def to_json(detections)
            ::JSON.pretty_generate(format(detections))
          end

          def build_rules(detections)
            rules = detections.flat_map do |detection|
              detection[:extensions].map do |ext|
                {
                  'id'                   => "detect/#{ext}",
                  'name'                 => detection[:name],
                  'shortDescription'     => { 'text' => "#{detection[:name]} detected — #{ext} recommended" },
                  'defaultConfiguration' => { 'level' => 'warning' }
                }
              end
            end
            rules.uniq { |r| r['id'] }
          end

          def build_results(detections)
            detections.flat_map do |detection|
              detection[:extensions].filter_map do |ext|
                next if detection[:installed][ext]

                {
                  'ruleId'     => "detect/#{ext}",
                  'level'      => 'warning',
                  'message'    => {
                    'text' => "#{detection[:name]} detected (#{detection[:matched_signals].join(', ')}) but #{ext} is not installed"
                  },
                  'properties' => {
                    'matched_signals' => detection[:matched_signals],
                    'detection_name'  => detection[:name]
                  }
                }
              end
            end
          end
        end
      end
    end
  end
end
