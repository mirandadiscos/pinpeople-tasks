class SurveyResponse < ApplicationRecord
  DEFAULT_PAGE = 1
  DEFAULT_PER_PAGE = 25
  MAX_PER_PAGE = 100
  MIN_FILTER_DATE = Date.new(1900, 1, 1)
  MAX_FILTER_DATE = Date.new(9999, 12, 31)
  LIKERT_RANGE = 1..7
  ENPS_RANGE = 0..10

  validates :name, :email, :corporate_email, :department, :role, :job_function, :location,
    :company_tenure, :gender, :generation, :level_0_company, :level_1_board,
    :level_2_management, :level_3_coordination, :level_4_area, :response_date,
    :interest_in_role, :contribution, :learning_and_development, :feedback,
    :manager_interaction, :career_clarity, :permanence_expectation, :enps,
    presence: true

  validates :interest_in_role, :contribution, :learning_and_development, :feedback,
    :manager_interaction, :career_clarity, :permanence_expectation,
    inclusion: { in: LIKERT_RANGE }
  validates :enps, inclusion: { in: ENPS_RANGE }

  scope :ordered_by_response_date, -> { order(response_date: :asc) }
  scope :by_response_date, ->(date) { where(response_date: date) }
  scope :between_response_dates, ->(from, to) { where(response_date: from..to) }
end
