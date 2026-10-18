class AddUserToCompanies < ActiveRecord::Migration[8.1]
  def change
    add_reference :companies, :user, foreign_key: true
    remove_index :companies, name: "index_companies_on_lower_name"
    add_index :companies, "user_id, lower(name)", unique: true, name: "index_companies_on_user_and_lower_name"
  end
end
