module V1
  class SurveyResponsesController < ApplicationController
    def index
      validate_date_filters!

      page = normalized_page
      per_page = normalized_per_page

      relation = filtered_relation
      total_count = relation.count
      total_pages = (total_count.to_f / per_page).ceil

      render json: {
        data: relation.page(page, per_page).map { |record| serialize_record(record) },
        meta: {
          page: page,
          per_page: per_page,
          total_count: total_count,
          total_pages: total_pages,
          filters: {
            date: params[:date].presence,
            from: params[:from].presence,
            to: params[:to].presence
          }
        }
      }
    rescue ArgumentError => e
      render_error(code: "unprocessable_entity", message: e.message, status: :unprocessable_content)
    end

    private

    def filtered_relation
      relation = SurveyResponse.ordered_by_response_date

      if params[:date].present?
        relation.by_response_date(parse_iso_date(params[:date], field: "date"))
      elsif params[:from].present? || params[:to].present?
        from_date = params[:from].present? ? parse_iso_date(params[:from], field: "from") : SurveyResponse::MIN_FILTER_DATE
        to_date = params[:to].present? ? parse_iso_date(params[:to], field: "to") : SurveyResponse::MAX_FILTER_DATE
        relation.between_response_dates(from_date, to_date)
      else
        relation
      end
    end

    def validate_date_filters!
      return unless params[:date].present? && (params[:from].present? || params[:to].present?)

      raise ArgumentError, "Use date or from/to, not both"
    end

    def parse_iso_date(value, field:)
      Date.iso8601(value)
    rescue Date::Error, ArgumentError
      raise ArgumentError, "#{field} must be in YYYY-MM-DD format"
    end

    def normalized_page
      value = params[:page].to_i
      value.positive? ? value : SurveyResponse::DEFAULT_PAGE
    end

    def normalized_per_page
      value = params[:per_page].to_i
      value = SurveyResponse::DEFAULT_PER_PAGE unless value.positive?
      [value, SurveyResponse::MAX_PER_PAGE].min
    end

    def serialize_record(record)
      attrs = record.attributes.symbolize_keys.slice(
        :name,
        :email,
        :corporate_email,
        :department,
        :role,
        :job_function,
        :location,
        :company_tenure,
        :gender,
        :generation,
        :level_0_company,
        :level_1_board,
        :level_2_management,
        :level_3_coordination,
        :level_4_area,
        :response_date,
        :interest_in_role,
        :interest_in_role_comment,
        :contribution,
        :contribution_comment,
        :learning_and_development,
        :learning_and_development_comment,
        :feedback,
        :feedback_comment,
        :manager_interaction,
        :manager_interaction_comment,
        :career_clarity,
        :career_clarity_comment,
        :permanence_expectation,
        :permanence_expectation_comment,
        :enps,
        :enps_comment
      )

      attrs.merge(response_date: record.response_date.iso8601)
    end
  end
end
