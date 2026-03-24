# frozen_string_literal: true

require 'json'

module Legion
  module Extensions
    module Detect
      module Formatters
        module Json
          module_function

          def format(detections)
            detections
          end

          def to_json(detections)
            ::JSON.pretty_generate(format(detections))
          end
        end
      end
    end
  end
end
