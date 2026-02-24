require 'rails_helper'

RSpec.describe ErrorMapper do
  describe '.call' do
    it 'maps parameter missing to bad_request' do
      error = ActionController::ParameterMissing.new(:date)

      mapped = described_class.call(error)

      expect(mapped).to be_a(ApiError)
      expect(mapped.code).to eq('bad_request')
      expect(mapped.message).to eq('Invalid parameters')
      expect(mapped.status).to eq(:bad_request)
    end

    it 'maps record not found to not_found' do
      error = ActiveRecord::RecordNotFound.new('missing')

      mapped = described_class.call(error)

      expect(mapped).to be_a(ApiError)
      expect(mapped.code).to eq('not_found')
      expect(mapped.message).to eq('Resource not found')
      expect(mapped.status).to eq(:not_found)
    end

    it 'maps record invalid to unprocessable_content' do
      record = SurveyResponse.new(normalized_db_attrs_row_1.merge(name: nil))
      error = ActiveRecord::RecordInvalid.new(record)

      mapped = described_class.call(error)

      expect(mapped).to be_a(ApiError)
      expect(mapped.code).to eq('unprocessable_content')
      expect(mapped.message).to eq('Validation failed')
      expect(mapped.status).to eq(:unprocessable_content)
    end

    it 'maps invalid filters error to unprocessable_content preserving message' do
      error = SurveyResponses::InvalidFiltersError.new('Use date or from/to, not both')

      mapped = described_class.call(error)

      expect(mapped).to be_a(ApiError)
      expect(mapped.code).to eq('unprocessable_content')
      expect(mapped.message).to eq('Use date or from/to, not both')
      expect(mapped.status).to eq(:unprocessable_content)
    end

    it 'maps unknown error to internal_error' do
      mapped = described_class.call(StandardError.new('boom'))

      expect(mapped).to be_a(ApiError)
      expect(mapped.code).to eq('internal_error')
      expect(mapped.message).to eq('Internal server error')
      expect(mapped.status).to eq(:internal_server_error)
    end

    it 'returns api_error as-is' do
      original = ApiError.new(code: 'bad_request', message: 'Invalid parameters', status: :bad_request)

      mapped = described_class.call(original)

      expect(mapped).to equal(original)
    end
  end
end
