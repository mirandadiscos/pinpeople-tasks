class CreateSurveyResponses < ActiveRecord::Migration[8.1]
  def change
    create_table :survey_responses do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :corporate_email, null: false
      t.string :department, null: false
      t.string :role, null: false
      t.string :job_function, null: false
      t.string :location, null: false
      t.string :company_tenure, null: false
      t.string :gender, null: false
      t.string :generation, null: false
      t.string :level_0_company, null: false
      t.string :level_1_board, null: false
      t.string :level_2_management, null: false
      t.string :level_3_coordination, null: false
      t.string :level_4_area, null: false

      t.date :response_date, null: false

      t.integer :interest_in_role, null: false
      t.text :interest_in_role_comment
      t.integer :contribution, null: false
      t.text :contribution_comment
      t.integer :learning_and_development, null: false
      t.text :learning_and_development_comment
      t.integer :feedback, null: false
      t.text :feedback_comment
      t.integer :manager_interaction, null: false
      t.text :manager_interaction_comment
      t.integer :career_clarity, null: false
      t.text :career_clarity_comment
      t.integer :permanence_expectation, null: false
      t.text :permanence_expectation_comment
      t.integer :enps, null: false
      t.text :enps_comment

      t.timestamps
    end

    add_index :survey_responses, [ :corporate_email, :response_date ], unique: true, name: "idx_survey_responses_corporate_email_response_date_uniq"
    add_index :survey_responses, :response_date
  end
end
