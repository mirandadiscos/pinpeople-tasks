module V1
  class SurveyResponsesController < BaseController
    rescue_from SurveyResponses::InvalidFiltersError do |error|
      render_error(code: "unprocessable_content", message: error.message, status: :unprocessable_content)
    end

    def index
      payload = SurveyResponses::Index::Service.new(params: index_params).call
      render_payload(payload)
    end

    private

    def index_params
      params.permit(:page, :per_page, :date, :from, :to)
    end
  end
end
