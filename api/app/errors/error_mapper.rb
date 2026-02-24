class ErrorMapper
  class << self
    def call(error)
      return error if error.is_a?(ApiError)

      case error
      when ActionController::ParameterMissing
        ApiError.new(code: "bad_request", message: "Invalid parameters", status: :bad_request)
      when ActiveRecord::RecordNotFound
        ApiError.new(code: "not_found", message: "Resource not found", status: :not_found)
      when ActiveRecord::RecordInvalid
        ApiError.new(code: "unprocessable_content", message: "Validation failed", status: :unprocessable_content)
      when SurveyResponses::InvalidFiltersError
        ApiError.new(code: "unprocessable_content", message: error.message, status: :unprocessable_content)
      else
        ApiError.new(code: "internal_error", message: "Internal server error", status: :internal_server_error)
      end
    end
  end
end
