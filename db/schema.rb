# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_17_030400) do
  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.string "website"
    t.string "industry"
    t.string "headquarters"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower(name)", name: "index_companies_on_lower_name", unique: true
  end

  create_table "job_applications", force: :cascade do |t|
    t.integer "company_id", null: false
    t.string "role_title", null: false
    t.string "status", default: "wishlist", null: false
    t.string "priority", default: "medium", null: false
    t.string "work_mode"
    t.string "location"
    t.string "source"
    t.string "job_url"
    t.string "salary_range"
    t.string "contact_name"
    t.string "contact_email"
    t.date "applied_on"
    t.date "follow_up_on"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "role_title"], name: "index_job_applications_on_company_id_and_role_title"
    t.index ["company_id"], name: "index_job_applications_on_company_id"
    t.index ["follow_up_on"], name: "index_job_applications_on_follow_up_on"
    t.index ["status"], name: "index_job_applications_on_status"
  end

  create_table "notes", force: :cascade do |t|
    t.integer "job_application_id", null: false
    t.text "body", null: false
    t.date "occurred_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_application_id"], name: "index_notes_on_job_application_id"
  end

  create_table "stage_changes", force: :cascade do |t|
    t.integer "job_application_id", null: false
    t.string "from_status"
    t.string "to_status", null: false
    t.datetime "changed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["changed_at"], name: "index_stage_changes_on_changed_at"
    t.index ["job_application_id"], name: "index_stage_changes_on_job_application_id"
  end

  add_foreign_key "job_applications", "companies"
  add_foreign_key "notes", "job_applications"
  add_foreign_key "stage_changes", "job_applications"
end
