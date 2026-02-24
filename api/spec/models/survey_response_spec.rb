require 'rails_helper'

RSpec.describe SurveyResponse do
  describe 'validations' do
    it 'is valid with normalized fixture attributes' do
      record = described_class.new(
        normalized_db_attrs_row_1.merge(
          email: 'validation001@pinpeople.com.br',
          corporate_email: 'validation001@pinpeople.com.br'
        )
      )

      expect(record).to be_valid
    end

    it 'requires required attributes' do
      record = described_class.new(
        normalized_db_attrs_row_1.merge(
          name: nil,
          email: 'validation002@pinpeople.com.br',
          corporate_email: 'validation002@pinpeople.com.br'
        )
      )

      expect(record).not_to be_valid
      expect(record.errors[:name]).to be_present
    end

    it 'validates likert scores in 1..7' do
      record = described_class.new(
        normalized_db_attrs_row_1.merge(
          email: 'validation003@pinpeople.com.br',
          corporate_email: 'validation003@pinpeople.com.br',
          feedback: 8
        )
      )

      expect(record).not_to be_valid
      expect(record.errors[:feedback]).to be_present
    end

    it 'validates enps in 0..10' do
      valid_record = described_class.new(
        normalized_db_attrs_row_1.merge(
          email: 'validation004a@pinpeople.com.br',
          corporate_email: 'validation004a@pinpeople.com.br',
          enps: 0
        )
      )

      expect(valid_record).to be_valid

      record = described_class.new(
        normalized_db_attrs_row_1.merge(
          email: 'validation004b@pinpeople.com.br',
          corporate_email: 'validation004b@pinpeople.com.br',
          enps: 11
        )
      )

      expect(record).not_to be_valid
      expect(record.errors[:enps]).to be_present
    end
  end

  describe 'query scopes' do
    let!(:response_1) do
      described_class.create!(
        normalized_db_attrs_row_1.merge(
          email: 'scope001@pinpeople.com.br',
          corporate_email: 'scope001@pinpeople.com.br',
          response_date: Date.new(2022, 1, 20)
        )
      )
    end

    let!(:response_2) do
      described_class.create!(
        normalized_db_attrs_row_2.merge(
          email: 'scope002@pinpeople.com.br',
          corporate_email: 'scope002@pinpeople.com.br',
          response_date: Date.new(2022, 1, 21)
        )
      )
    end

    let!(:response_3) do
      described_class.create!(
        normalized_db_attrs_row_2.merge(
          email: 'scope003@pinpeople.com.br',
          corporate_email: 'scope003@pinpeople.com.br',
          response_date: Date.new(2022, 1, 22)
        )
      )
    end

    it 'orders by response_date ascending' do
      ordered = described_class.ordered_by_response_date

      expect(ordered.pluck(:response_date)).to eq(
        [ Date.new(2022, 1, 20), Date.new(2022, 1, 21), Date.new(2022, 1, 22) ]
      )
    end

    it 'filters by exact response_date' do
      filtered = described_class.by_response_date(Date.new(2022, 1, 20))

      expect(filtered.pluck(:id)).to contain_exactly(response_1.id)
    end

    it 'filters by inclusive response_date range' do
      filtered = described_class.between_response_dates(Date.new(2022, 1, 21), Date.new(2022, 1, 22))

      expect(filtered.pluck(:id)).to contain_exactly(response_2.id, response_3.id)
    end

    it 'paginates based on page and per_page' do
      paginated = described_class.ordered_by_response_date.page(2, 1)

      expect(paginated.pluck(:id)).to contain_exactly(response_2.id)
    end

    it 'falls back to safe pagination defaults for invalid values' do
      paginated = described_class.ordered_by_response_date.page(0, 0)

      expect(paginated.pluck(:id)).to match_array([ response_1.id, response_2.id, response_3.id ])
    end
  end
end
