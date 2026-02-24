class ApplicationController < ActionController::API
  before_action :authenticate_api_request!

  rescue_from ActionController::ParameterMissing do
    render_error(code: "bad_request", message: "Invalid parameters", status: :bad_request)
  end

  rescue_from ActiveRecord::RecordNotFound do
    render_error(code: "not_found", message: "Resource not found", status: :not_found)
  end

  rescue_from ActiveRecord::RecordInvalid do
    render_error(code: "unprocessable_entity", message: "Validation failed", status: :unprocessable_content)
  end

  rescue_from StandardError do |error|
    Rails.logger.error("[api_error] #{error.class}: #{error.message}")
    render_error(code: "internal_error", message: "Internal server error", status: :internal_server_error)
  end

  private

  def authenticate_api_request!
    return if public_endpoint?
    return if request.options?

    token, = ActionController::HttpAuthentication::Token.token_and_options(request)
    return if valid_api_token?(token)

    render_error(code: "unauthorized", message: "Unauthorized", status: :unauthorized)
  end

  def valid_api_token?(token)
    expected_token = ENV["API_AUTH_TOKEN"].to_s
    return false if token.blank? || expected_token.blank?
    return false unless token.bytesize == expected_token.bytesize

    ActiveSupport::SecurityUtils.secure_compare(token, expected_token)
  end

  def public_endpoint?
    request.path == "/up" || request.path.start_with?("/api-docs")
  end

  def render_error(code:, message:, status:)
    render json: { error: { code: code, message: message } }, status: status
  end
end
