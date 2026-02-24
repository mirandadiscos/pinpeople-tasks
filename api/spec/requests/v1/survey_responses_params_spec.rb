require 'rails_helper'

RSpec.describe 'V1::SurveyResponses params', type: :request do
  let(:token) { 'test-api-token' }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('API_AUTH_TOKEN').and_return(token)
  end

  it 'passes only permitted params to the index service' do
    service = instance_double(SurveyResponses::Index::Service, call: { data: [], meta: {} })

    expect(SurveyResponses::Index::Service).to receive(:new) do |params:|
      expect(params).to be_permitted
      expect(params.to_h.keys).to match_array(%w[page per_page date from to])
      expect(params.to_h).to eq(
        'page' => '1',
        'per_page' => '10',
        'date' => '2022-01-20',
        'from' => '2022-01-01',
        'to' => '2022-01-31'
      )
      expect(params.to_h).not_to have_key('admin')

      service
    end

    get '/v1/survey_responses',
      params: {
        page: 1,
        per_page: 10,
        date: '2022-01-20',
        from: '2022-01-01',
        to: '2022-01-31',
        admin: true
      },
      headers: headers

    expect(response).to have_http_status(:ok)
  end
end
