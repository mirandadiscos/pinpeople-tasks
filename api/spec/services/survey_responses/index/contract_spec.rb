require 'rails_helper'

RSpec.describe SurveyResponses::Index::Contract do
  subject(:contract) { described_class.new }

  it 'accepts empty filters' do
    result = contract.call({})

    expect(result).to be_success
  end

  it 'rejects mixed date and from/to filters' do
    result = contract.call(date: '2022-01-20', from: '2022-01-01')

    expect(result).to be_failure
    expect(result.errors.to_h).to include(date: include('Use date or from/to, not both'))
  end

  it 'rejects invalid date format' do
    result = contract.call(date: '20-01-2022')

    expect(result).to be_failure
    expect(result.errors.to_h).to include(date: include('date must be in YYYY-MM-DD format'))
  end

  it 'rejects invalid from format' do
    result = contract.call(from: '2022/01/20')

    expect(result).to be_failure
    expect(result.errors.to_h).to include(from: include('from must be in YYYY-MM-DD format'))
  end

  it 'rejects invalid to format' do
    result = contract.call(to: '2022/01/20')

    expect(result).to be_failure
    expect(result.errors.to_h).to include(to: include('to must be in YYYY-MM-DD format'))
  end
end
