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

  scope :page, lambda { |number, per_page|
    page_number = number.to_i
    page_number = DEFAULT_PAGE if page_number <= 0

    per_page_value = per_page.to_i
    per_page_value = DEFAULT_PER_PAGE if per_page_value <= 0
    per_page_value = [per_page_value, MAX_PER_PAGE].min

    offset((page_number - 1) * per_page_value).limit(per_page_value)
  }
end
