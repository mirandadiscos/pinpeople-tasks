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

ActiveRecord::Schema[8.1].define(version: 2026_02_24_123000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "survey_responses", force: :cascade do |t|
    t.integer "career_clarity", null: false
    t.text "career_clarity_comment"
    t.string "company_tenure", null: false
    t.integer "contribution", null: false
    t.text "contribution_comment"
    t.string "corporate_email", null: false
    t.datetime "created_at", null: false
    t.string "department", null: false
    t.string "email", null: false
    t.integer "enps", null: false
    t.text "enps_comment"
    t.integer "feedback", null: false
    t.text "feedback_comment"
    t.string "gender", null: false
    t.string "generation", null: false
    t.integer "interest_in_role", null: false
    t.text "interest_in_role_comment"
    t.string "job_function", null: false
    t.integer "learning_and_development", null: false
    t.text "learning_and_development_comment"
    t.string "level_0_company", null: false
    t.string "level_1_board", null: false
    t.string "level_2_management", null: false
    t.string "level_3_coordination", null: false
    t.string "level_4_area", null: false
    t.string "location", null: false
    t.integer "manager_interaction", null: false
    t.text "manager_interaction_comment"
    t.string "name", null: false
    t.integer "permanence_expectation", null: false
    t.text "permanence_expectation_comment"
    t.date "response_date", null: false
    t.string "role", null: false
    t.datetime "updated_at", null: false
    t.index ["corporate_email", "response_date"], name: "idx_survey_responses_corporate_email_response_date_uniq", unique: true
    t.index ["response_date"], name: "index_survey_responses_on_response_date"
  end
end
