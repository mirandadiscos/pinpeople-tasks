module SurveyResponses
  module Index
    class Query
      class << self
        def call(date:, from:, to:)
          query = SurveyResponse.ordered_by_response_date

          if date.present?
            query.by_response_date(date)
          elsif from.present? || to.present?
            from_date = from.presence || SurveyResponse::MIN_FILTER_DATE
            to_date = to.presence || SurveyResponse::MAX_FILTER_DATE
            query.between_response_dates(from_date, to_date)
          else
            query
          end
        end
      end
    end
  end
end
