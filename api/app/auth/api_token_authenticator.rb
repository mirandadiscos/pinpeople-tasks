class ApiTokenAuthenticator
  def initialize(request:, expected_token: ENV["API_AUTH_TOKEN"].to_s)
    @request = request
    @expected_token = expected_token
  end

  def valid?
    token, = ActionController::HttpAuthentication::Token.token_and_options(request)
    return false if token.blank? || expected_token.blank?
    return false unless token.bytesize == expected_token.bytesize

    ActiveSupport::SecurityUtils.secure_compare(token, expected_token)
  end

  private

  attr_reader :request, :expected_token
end
