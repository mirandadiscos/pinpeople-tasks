module SurveyResponses
  class IndexService
    def initialize(params:)
      @params = params
    end

    def call
      parsed = IndexParams.new(params).to_h
      relation = IndexQuery.call(date: parsed[:date], from: parsed[:from], to: parsed[:to])

      total_count = relation.count
      per_page = parsed[:per_page]
      page = parsed[:page]

      {
        data: paginated(relation, page: page, per_page: per_page).map { 
          |record| SurveyResponseSerializer.new(record).as_json 
        },
        meta: {
          page: page,
          per_page: per_page,
          total_count: total_count,
          total_pages: (total_count.to_f / per_page).ceil,
          filters: parsed[:raw_filters]
        }
      }
    end

    private

    attr_reader :params

    def paginated(relation, page:, per_page:)
      relation.offset((page - 1) * per_page).limit(per_page)
    end
  end
end
