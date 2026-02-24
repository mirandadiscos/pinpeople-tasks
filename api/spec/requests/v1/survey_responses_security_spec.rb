require 'rails_helper'

RSpec.describe 'V1::SurveyResponses security', type: :request do
  let(:path) { '/v1/survey_responses' }
  let(:token) { 'test-api-token' }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('API_AUTH_TOKEN').and_return(token)
  end

  context 'without authorization header' do
    before { get path }

    it_behaves_like 'unauthorized response contract'
  end

  context 'with invalid token' do
    before { get path, headers: { 'Authorization' => 'Bearer wrong-token' } }

    it_behaves_like 'unauthorized response contract'
  end
end
