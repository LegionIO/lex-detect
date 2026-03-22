# frozen_string_literal: true

require 'legion/extensions/detect/formatters/json'
require 'legion/extensions/detect/formatters/sarif'
require 'legion/extensions/detect/formatters/markdown_pr'

module Legion
  module Extensions
    module Detect
      module Formatters
        module_function

        def format(detections, format: :json)
          case format.to_sym
          when :sarif    then Sarif.to_json(detections)
          when :markdown then MarkdownPr.format(detections)
          else Json.format(detections)
          end
        end
      end
    end
  end
end
