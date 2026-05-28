# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:detect_results) do
      add_index :name, name: :idx_detect_results_name
      add_index :scanned_at, name: :idx_detect_results_scanned_at
    end
  end

  down do
    alter_table(:detect_results) do
      drop_index :scanned_at, name: :idx_detect_results_scanned_at
      drop_index :name, name: :idx_detect_results_name
    end
  end
end
