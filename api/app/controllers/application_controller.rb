class ApplicationController < ActionController::API
  before_action :authenticate_api_request!

  rescue_from ActionController::ParameterMissing do
    render_error(code: "bad_request", message: "Invalid parameters", status: :bad_request)
  end

  rescue_from ActiveRecord::RecordNotFound do
    render_error(code: "not_found", message: "Resource not found", status: :not_found)
  end

  rescue_from ActiveRecord::RecordInvalid do
    render_error(code: "unprocessable_content", message: "Validation failed", status: :unprocessable_content)
  end

  rescue_from StandardError do |error|
    Rails.logger.error(
      "[api_error] request_id=#{request.request_id} class=#{error.class} message=#{error.message}"
    )
    render_error(code: "internal_error", message: "Internal server error", status: :internal_server_error)
  end

  private

  def authenticate_api_request!
    return if public_endpoint?
    return if request.options?
    return if ApiTokenAuthenticator.new(request: request).valid?

    render_error(code: "unauthorized", message: "Unauthorized", status: :unauthorized)
  end

  def public_endpoint?
    request.path == "/up" || request.path.start_with?("/api-docs")
  end

  def render_error(code:, message:, status:)
    render json: { error: { code: code, message: message } }, status: status
  end
end
