require 'rails_helper'

RSpec.describe SurveyResponses::IndexService do
  let!(:response_1) do
    SurveyResponse.create!(
      normalized_db_attrs_row_1.merge(
        email: 'service001@pinpeople.com.br',
        corporate_email: 'service001@pinpeople.com.br',
        response_date: Date.new(2022, 1, 20)
      )
    )
  end

  let!(:response_2) do
    SurveyResponse.create!(
      normalized_db_attrs_row_2.merge(
        email: 'service002@pinpeople.com.br',
        corporate_email: 'service002@pinpeople.com.br',
        response_date: Date.new(2022, 1, 21)
      )
    )
  end

  let!(:response_3) do
    SurveyResponse.create!(
      normalized_db_attrs_row_2.merge(
        email: 'service003@pinpeople.com.br',
        corporate_email: 'service003@pinpeople.com.br',
        response_date: Date.new(2022, 1, 22)
      )
    )
  end

  it 'returns paginated payload with metadata' do
    params = ActionController::Parameters.new(page: 2, per_page: 1)

    payload = described_class.new(params: params).call

    expect(payload[:data].size).to eq(1)
    expect(payload[:data].first[:response_date]).to eq('2022-01-21')
    expect(payload[:meta]).to include(page: 2, per_page: 1, total_count: 3, total_pages: 3)
  end

  it 'returns filter metadata as raw input values' do
    params = ActionController::Parameters.new(date: '2022-01-20')

    payload = described_class.new(params: params).call

    expect(payload[:meta][:filters]).to eq({ date: '2022-01-20', from: nil, to: nil })
  end
end
