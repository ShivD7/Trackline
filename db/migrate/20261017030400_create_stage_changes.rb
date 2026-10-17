class CreateStageChanges < ActiveRecord::Migration[8.1]
  def change
    create_table :stage_changes do |t|
      t.references :job_application, null: false, foreign_key: true
      t.string :from_status
      t.string :to_status, null: false
      t.datetime :changed_at, null: false

      t.timestamps
    end

    add_index :stage_changes, :changed_at
  end
end
