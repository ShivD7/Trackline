class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :website
      t.string :industry
      t.string :headquarters

      t.timestamps
    end

    add_index :companies, "lower(name)", unique: true, name: "index_companies_on_lower_name"
  end
end
