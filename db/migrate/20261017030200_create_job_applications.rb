class CreateJobApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :job_applications do |t|
      t.references :company, null: false, foreign_key: true
      t.string :role_title, null: false
      t.string :status, null: false, default: "wishlist"
      t.string :priority, null: false, default: "medium"
      t.string :work_mode
      t.string :location
      t.string :source
      t.string :job_url
      t.string :salary_range
      t.string :contact_name
      t.string :contact_email
      t.date :applied_on
      t.date :follow_up_on
      t.text :description

      t.timestamps
    end

    add_index :job_applications, :status
    add_index :job_applications, :follow_up_on
    add_index :job_applications, %i[company_id role_title]
  end
end
