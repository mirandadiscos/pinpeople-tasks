require 'rails_helper'

RSpec.describe SurveyResponses::IndexQuery do
  let!(:response_1) do
    SurveyResponse.create!(
      normalized_db_attrs_row_1.merge(
        email: 'query001@pinpeople.com.br',
        corporate_email: 'query001@pinpeople.com.br',
        response_date: Date.new(2022, 1, 20)
      )
    )
  end

  let!(:response_2) do
    SurveyResponse.create!(
      normalized_db_attrs_row_2.merge(
        email: 'query002@pinpeople.com.br',
        corporate_email: 'query002@pinpeople.com.br',
        response_date: Date.new(2022, 1, 21)
      )
    )
  end

  let!(:response_3) do
    SurveyResponse.create!(
      normalized_db_attrs_row_2.merge(
        email: 'query003@pinpeople.com.br',
        corporate_email: 'query003@pinpeople.com.br',
        response_date: Date.new(2022, 1, 22)
      )
    )
  end

  it 'filters by exact date' do
    relation = described_class.call(date: Date.new(2022, 1, 21), from: nil, to: nil)

    expect(relation.pluck(:id)).to eq([ response_2.id ])
  end

  it 'filters by range when from/to are provided' do
    relation = described_class.call(date: nil, from: Date.new(2022, 1, 21), to: Date.new(2022, 1, 22))

    expect(relation.pluck(:id)).to eq([ response_2.id, response_3.id ])
  end

  it 'returns all ordered when no filters are provided' do
    relation = described_class.call(date: nil, from: nil, to: nil)

    expect(relation.pluck(:id)).to eq([ response_1.id, response_2.id, response_3.id ])
  end
end
