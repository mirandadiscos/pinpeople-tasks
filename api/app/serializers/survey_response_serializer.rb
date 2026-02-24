class SurveyResponseSerializer
  ATTRIBUTES = %i[
    name
    email
    corporate_email
    department
    role
    job_function
    location
    company_tenure
    gender
    generation
    level_0_company
    level_1_board
    level_2_management
    level_3_coordination
    level_4_area
    response_date
    interest_in_role
    interest_in_role_comment
    contribution
    contribution_comment
    learning_and_development
    learning_and_development_comment
    feedback
    feedback_comment
    manager_interaction
    manager_interaction_comment
    career_clarity
    career_clarity_comment
    permanence_expectation
    permanence_expectation_comment
    enps
    enps_comment
  ].freeze

  def initialize(record)
    @record = record
  end

  def as_json(*)
    attrs = record.attributes.symbolize_keys.slice(*ATTRIBUTES)
    attrs.merge(response_date: record.response_date.iso8601)
  end

  private

  attr_reader :record
end
