class ApplicationController < ActionController::API
  before_action :authenticate_api_request!

  rescue_from StandardError, with: :render_mapped_error

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

  def render_mapped_error(error)
    api_error = ErrorMapper.call(error)

    Rails.logger.error(
      "[api_error] request_id=#{request.request_id} method=#{request.method} path=#{request.path} " \
      "class=#{error.class} code=#{api_error.code} status=#{api_error.status} message=#{error.message}"
    )

    render_error(code: api_error.code, message: api_error.message, status: api_error.status)
  end
end
