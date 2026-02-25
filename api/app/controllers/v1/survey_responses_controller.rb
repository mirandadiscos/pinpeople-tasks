module V1
  class SurveyResponsesController < BaseController
    def index
      payload = SurveyResponses::Index::UseCase.new(params: index_params).call
      render_payload(payload)
    end

    private

    def index_params
      params.permit(:page, :per_page, :date, :from, :to)
    end
  end
end
