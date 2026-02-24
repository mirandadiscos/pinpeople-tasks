module SurveyResponses
  class IndexParams
    def initialize(params)
      @params = params
    end

    def to_h
      validate_date_filters!

      {
        page: normalized_page,
        per_page: normalized_per_page,
        date: parsed_date,
        from: parsed_from,
        to: parsed_to,
        raw_filters: {
          date: params[:date].presence,
          from: params[:from].presence,
          to: params[:to].presence
        }
      }
    end

    private

    attr_reader :params

    def validate_date_filters!
      return unless params[:date].present? && (params[:from].present? || params[:to].present?)

      raise InvalidFiltersError, "Use date or from/to, not both"
    end

    def parsed_date
      return if params[:date].blank?

      parse_iso_date(params[:date], field: "date")
    end

    def parsed_from
      return if params[:from].blank?

      parse_iso_date(params[:from], field: "from")
    end

    def parsed_to
      return if params[:to].blank?

      parse_iso_date(params[:to], field: "to")
    end

    def parse_iso_date(value, field:)
      Date.iso8601(value)
    rescue Date::Error, ArgumentError
      raise InvalidFiltersError, "#{field} must be in YYYY-MM-DD format"
    end

    def normalized_page
      value = params[:page].to_i
      value.positive? ? value : SurveyResponse::DEFAULT_PAGE
    end

    def normalized_per_page
      value = params[:per_page].to_i
      value = SurveyResponse::DEFAULT_PER_PAGE unless value.positive?
      [ value, SurveyResponse::MAX_PER_PAGE ].min
    end
  end
end
