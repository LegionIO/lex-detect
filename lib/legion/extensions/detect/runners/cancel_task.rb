# frozen_string_literal: true

module Legion
  module Extensions
    module Detect
      module Runners
        module CancelTask # rubocop:disable Legion/Extension/RunnerIncludeHelpers
          def cancel_task(task_id:, **)
            return { success: false, reason: :data_unavailable } unless defined?(Legion::Data)

            task = Legion::Data::Model::Task[task_id]
            return { success: false, reason: :not_found } unless task
            return { success: false, reason: :already_cancelled } if task.respond_to?(:cancelled?) && task.cancelled?

            task.update(cancelled_at: Time.now.utc)
            { success: true, task_id: task_id, cancelled_at: task.cancelled_at }
          rescue StandardError => e
            { success: false, reason: :error, message: e.message }
          end
        end
      end
    end
  end
end
