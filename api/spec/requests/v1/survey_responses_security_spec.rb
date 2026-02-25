require 'rails_helper'

RSpec.describe 'V1::SurveyResponses security', type: :request do
  let(:path) { '/v1/survey_responses' }
  let(:token) { 'test-api-token' }
  let(:origin) { 'http://localhost:3000' }

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

  describe 'CORS policy' do
    it 'allows preflight for GET and does not advertise mutating methods' do
      options path, headers: {
        'Origin' => origin,
        'Access-Control-Request-Method' => 'GET',
        'Access-Control-Request-Headers' => 'Authorization'
      }

      allow_methods = response.headers['Access-Control-Allow-Methods'].to_s.upcase

      expect(allow_methods).to include('GET')
      expect(allow_methods).to include('OPTIONS')
      expect(allow_methods).to include('HEAD')
      expect(allow_methods).not_to include('POST')
      expect(allow_methods).not_to include('PUT')
      expect(allow_methods).not_to include('PATCH')
      expect(allow_methods).not_to include('DELETE')
    end
  end
end
