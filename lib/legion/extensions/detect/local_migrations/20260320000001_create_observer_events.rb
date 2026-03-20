# frozen_string_literal: true

Sequel.migration do
  up do
    create_table?(:observer_events) do
      primary_key :id
      String :task_id, size: 64
      String :runner, size: 255
      String :rule, size: 64, null: true
      String :severity, size: 16, null: true
      Float :duration, null: true
      Float :token_cost, null: true
      DateTime :observed_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      index :task_id
      index :rule
      index :observed_at
    end
  end

  down do
    drop_table?(:observer_events)
  end
end
