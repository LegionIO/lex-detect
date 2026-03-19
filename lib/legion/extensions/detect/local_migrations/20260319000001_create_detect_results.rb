# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:detect_results) do
      primary_key :id
      String :name, null: false
      String :extensions, text: true
      String :matched_signals, text: true
      String :installed, text: true
      Time :scanned_at
      Time :created_at
      Time :updated_at
    end
  end
end
