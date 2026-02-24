require 'rails_helper'

RSpec.describe SurveyResponses::Index::Service do
  let!(:response_1) do
    SurveyResponse.create!(
      normalized_db_attrs_row_1.merge(
        email: 'indexservice001@pinpeople.com.br',
        corporate_email: 'indexservice001@pinpeople.com.br',
        response_date: Date.new(2022, 1, 20)
      )
    )
  end

  let!(:response_2) do
    SurveyResponse.create!(
      normalized_db_attrs_row_2.merge(
        email: 'indexservice002@pinpeople.com.br',
        corporate_email: 'indexservice002@pinpeople.com.br',
        response_date: Date.new(2022, 1, 21)
      )
    )
  end

  let!(:response_3) do
    SurveyResponse.create!(
      normalized_db_attrs_row_2.merge(
        email: 'indexservice003@pinpeople.com.br',
        corporate_email: 'indexservice003@pinpeople.com.br',
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

  it 'raises invalid filters error for mixed date and range' do
    params = ActionController::Parameters.new(date: '2022-01-20', from: '2022-01-01')

    expect { described_class.new(params: params).call }
      .to raise_error(SurveyResponses::InvalidFiltersError, 'Use date or from/to, not both')
  end

  it 'raises invalid filters error for invalid date format' do
    params = ActionController::Parameters.new(date: '20-01-2022')

    expect { described_class.new(params: params).call }
      .to raise_error(SurveyResponses::InvalidFiltersError, 'date must be in YYYY-MM-DD format')
  end
end

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
