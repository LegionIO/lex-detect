# frozen_string_literal: true

module Legion
  module Extensions
    module Detect
      module Actor
        class ObserverTick < Legion::Extensions::Actors::Every
          def runner_class
            self.class
          end

          def time = 60
          def run_now? = false
          def use_runner? = false
          def check_subtask? = false
          def generate_task? = false

          def action(**_opts)
            observer = Object.new.extend(Runners::TaskObserver)
            observer.observe(since: @last_tick || (Time.now - 60))
          ensure
            @last_tick = Time.now
          end
        end
      end
    end
  end
end
