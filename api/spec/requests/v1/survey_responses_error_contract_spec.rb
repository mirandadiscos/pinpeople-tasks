require 'rails_helper'

RSpec.describe 'V1::SurveyResponses error contract', type: :request do
  let(:token) { 'test-api-token' }
  let(:auth_headers) { { 'Authorization' => "Bearer #{token}" } }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('API_AUTH_TOKEN').and_return(token)

    SurveyResponse.create!(
      normalized_db_attrs_row_1.merge(
        email: 'request_error001@pinpeople.com.br',
        corporate_email: 'request_error001@pinpeople.com.br'
      )
    )
  end

  context 'when date is mixed with from/to' do
    before do
      get '/v1/survey_responses',
        params: { date: '2022-01-20', from: '2022-01-01', to: '2022-01-31' },
        headers: auth_headers
    end

    it_behaves_like 'error object response',
      status: :unprocessable_content,
      code: 'unprocessable_content',
      message: 'Use date or from/to, not both'
  end
end
