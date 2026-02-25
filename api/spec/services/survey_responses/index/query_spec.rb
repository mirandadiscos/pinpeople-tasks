require 'rails_helper'

RSpec.describe SurveyResponses::Index::Query do
  let!(:response_1) do
    SurveyResponse.create!(
      normalized_db_attrs_row_1.merge(
        email: 'indexquery001@pinpeople.com.br',
        corporate_email: 'indexquery001@pinpeople.com.br',
        response_date: Date.new(2022, 1, 20)
      )
    )
  end

  let!(:response_2) do
    SurveyResponse.create!(
      normalized_db_attrs_row_2.merge(
        email: 'indexquery002@pinpeople.com.br',
        corporate_email: 'indexquery002@pinpeople.com.br',
        response_date: Date.new(2022, 1, 21)
      )
    )
  end

  let!(:response_3) do
    SurveyResponse.create!(
      normalized_db_attrs_row_2.merge(
        email: 'indexquery003@pinpeople.com.br',
        corporate_email: 'indexquery003@pinpeople.com.br',
        response_date: Date.new(2022, 1, 22)
      )
    )
  end

  it 'filters by exact date' do
    query = described_class.call(date: Date.new(2022, 1, 21), from: nil, to: nil)

    expect(query.pluck(:id)).to eq([ response_2.id ])
  end

  it 'filters by range when from/to are provided' do
    query = described_class.call(date: nil, from: Date.new(2022, 1, 21), to: Date.new(2022, 1, 22))

    expect(query.pluck(:id)).to eq([ response_2.id, response_3.id ])
  end

  it 'filters by open-ended range when only from is provided' do
    query = described_class.call(date: nil, from: Date.new(2022, 1, 21), to: nil)

    expect(query.pluck(:id)).to eq([ response_2.id, response_3.id ])
  end

  it 'filters by open-ended range when only to is provided' do
    query = described_class.call(date: nil, from: nil, to: Date.new(2022, 1, 21))

    expect(query.pluck(:id)).to eq([ response_1.id, response_2.id ])
  end

  it 'returns all ordered when no filters are provided' do
    query = described_class.call(date: nil, from: nil, to: nil)

    expect(query.pluck(:id)).to eq([ response_1.id, response_2.id, response_3.id ])
  end
end
