require 'rails_helper'

RSpec.describe SurveyResponses::IndexParams do
  describe '#to_h' do
    it 'returns normalized defaults when pagination params are invalid' do
      result = described_class.new(ActionController::Parameters.new(page: 0, per_page: 0)).to_h

      expect(result).to include(
        page: 1,
        per_page: 25,
        date: nil,
        from: nil,
        to: nil,
        raw_filters: { date: nil, from: nil, to: nil }
      )
    end

    it 'caps per_page to max allowed' do
      result = described_class.new(ActionController::Parameters.new(per_page: 500)).to_h

      expect(result[:per_page]).to eq(100)
    end

    it 'parses date filters as Date' do
      result = described_class.new(ActionController::Parameters.new(date: '2022-01-20')).to_h

      expect(result[:date]).to eq(Date.new(2022, 1, 20))
      expect(result[:from]).to be_nil
      expect(result[:to]).to be_nil
    end

    it 'raises when mixing date and from/to' do
      params = ActionController::Parameters.new(date: '2022-01-20', from: '2022-01-01')

      expect { described_class.new(params).to_h }
        .to raise_error(SurveyResponses::InvalidFiltersError, 'Use date or from/to, not both')
    end

    it 'raises when date format is invalid' do
      params = ActionController::Parameters.new(date: '20-01-2022')

      expect { described_class.new(params).to_h }
        .to raise_error(SurveyResponses::InvalidFiltersError, 'date must be in YYYY-MM-DD format')
    end
  end
end
