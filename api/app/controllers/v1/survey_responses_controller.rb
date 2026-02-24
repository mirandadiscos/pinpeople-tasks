module V1
  class SurveyResponsesController < BaseController
    rescue_from SurveyResponses::InvalidFiltersError do |error|
      render_error(code: "unprocessable_content", message: error.message, status: :unprocessable_content)
    end

    def index
      payload = SurveyResponses::IndexService.new(params: params).call
      render_payload(payload)
    end
  end
end
