module SurveyResponses
  module Index
    class Query
      class << self
        def call(date:, from:, to:)
          relation = SurveyResponse.ordered_by_response_date

          if date.present?
            relation.by_response_date(date)
          elsif from.present? || to.present?
            from_date = from.presence || SurveyResponse::MIN_FILTER_DATE
            to_date = to.presence || SurveyResponse::MAX_FILTER_DATE
            relation.between_response_dates(from_date, to_date)
          else
            relation
          end
        end
      end
    end

    class Service
      def initialize(params:)
        @params = params
      end

      def call
        input = sanitized_input
        contract = Contract.new
        result = contract.call(input)
        raise InvalidFiltersError, first_error_message(result) if result.failure?

        validated_input = contract.coerce_dates(result.to_h)
        relation = Query.call(
          date: validated_input[:date],
          from: validated_input[:from],
          to: validated_input[:to]
        )

        page = normalized_page(validated_input[:page])
        per_page = normalized_per_page(validated_input[:per_page])
        total_count = relation.count

        {
          data: paginated(relation, page: page, per_page: per_page).map do |record|
            SurveyResponseSerializer.new(record).as_json
          end,
          meta: {
            page: page,
            per_page: per_page,
            total_count: total_count,
            total_pages: (total_count.to_f / per_page).ceil,
            filters: {
              date: input[:date].presence,
              from: input[:from].presence,
              to: input[:to].presence
            }
          }
        }
      end

      private

      attr_reader :params

      def sanitized_input
        raw = params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params.to_h
        raw.symbolize_keys.slice(:page, :per_page, :date, :from, :to)
      end

      def first_error_message(result)
        errors = result.errors.to_h
        key, messages = errors.first
        message = Array(messages).first

        return "Invalid parameters" if message.blank?
        message
      end

      def normalized_page(value)
        page = value.to_i
        page.positive? ? page : SurveyResponse::DEFAULT_PAGE
      end

      def normalized_per_page(value)
        per_page = value.to_i
        per_page = SurveyResponse::DEFAULT_PER_PAGE unless per_page.positive?
        [ per_page, SurveyResponse::MAX_PER_PAGE ].min
      end

      def paginated(relation, page:, per_page:)
        relation.offset((page - 1) * per_page).limit(per_page)
      end
    end
  end
end
