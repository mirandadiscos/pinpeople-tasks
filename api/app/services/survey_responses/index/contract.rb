module SurveyResponses
  module Index
    class Contract < Dry::Validation::Contract
      params do
        optional(:page)
        optional(:per_page)
        optional(:date).maybe(:string)
        optional(:from).maybe(:string)
        optional(:to).maybe(:string)
      end

      rule(:date, :from, :to) do
        next unless values[:date].present?
        next if values[:from].blank? && values[:to].blank?

        key(:date).failure("Use date or from/to, not both")
      end

      rule(:date) do
        next if value.blank?

        key.failure("date must be in YYYY-MM-DD format") unless iso8601_date?(value)
      end

      rule(:from) do
        next if value.blank?

        key.failure("from must be in YYYY-MM-DD format") unless iso8601_date?(value)
      end

      rule(:to) do
        next if value.blank?

        key.failure("to must be in YYYY-MM-DD format") unless iso8601_date?(value)
      end

      def coerce_dates(values)
        values.merge(
          date: coerce_iso_date(values[:date]),
          from: coerce_iso_date(values[:from]),
          to: coerce_iso_date(values[:to])
        )
      end

      private

      def iso8601_date?(value)
        Date.iso8601(value)
        true
      rescue Date::Error, ArgumentError
        false
      end

      def coerce_iso_date(value)
        return if value.blank?

        Date.iso8601(value)
      end
    end
  end
end
