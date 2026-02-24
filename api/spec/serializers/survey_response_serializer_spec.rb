require 'rails_helper'

RSpec.describe SurveyResponseSerializer do
  it 'serializes only exposed attributes and formats response_date' do
    record = SurveyResponse.create!(
      normalized_db_attrs_row_1.merge(
        email: 'serializer001@pinpeople.com.br',
        corporate_email: 'serializer001@pinpeople.com.br',
        response_date: Date.new(2022, 1, 20)
      )
    )

    payload = described_class.new(record).as_json

    expect(payload[:name]).to eq(record.name)
    expect(payload[:response_date]).to eq('2022-01-20')
    expect(payload.keys).not_to include(:id, :created_at, :updated_at)
  end
end
