require 'rails_helper'
require 'csv'

RSpec.describe SurveyResponses::CsvImporter do
  let(:file_path) { '../data.csv' }
  let(:row_1) { instance_double(CSV::Row, to_h: csv_pt_br_row_1) }
  let(:row_2) { instance_double(CSV::Row, to_h: csv_pt_br_row_2) }

  before do
    allow(CSV).to receive(:foreach)
      .with(file_path, headers: true, col_sep: ';')
      .and_return([row_1, row_2].each)

    allow(SurveyResponse).to receive(:create!)
  end

  it 'iterates through CSV rows and persists one normalized record per row' do
    result = described_class.call(file_path: file_path)

    expect(CSV).to have_received(:foreach).with(file_path, headers: true, col_sep: ';')
    expect(SurveyResponse).to have_received(:create!).twice
    expect(result).to include(processed: 2, created: 2, failed: 0, file: file_path)
    expect(result[:duration_ms]).to be_a(Integer)
    expect(result[:duration_ms]).to be >= 0
    expect(result[:errors]).to eq([])
    expect(result[:warnings]).to all(include(:line, :field, :value, :message))
  end

  it 'normalizes all fields from pt-BR CSV headers to english DB attributes' do
    described_class.call(file_path: file_path)

    expect(SurveyResponse).to have_received(:create!).with(hash_including(normalized_db_attrs_row_1))
    expect(SurveyResponse).to have_received(:create!).with(hash_including(normalized_db_attrs_row_2))
  end

  it 'continues import when one row fails and tracks line/error' do
    allow(SurveyResponse).to receive(:create!).with(hash_including(normalized_db_attrs_row_1)).and_raise(StandardError, 'invalid row')

    result = described_class.call(file_path: file_path)

    expect(result).to include(processed: 2, created: 1, failed: 1, file: file_path)
    expect(result[:duration_ms]).to be_a(Integer)
    expect(result[:errors]).to include(include(line: 2, error: 'invalid row'))
  end

  it 'returns explicit response_date missing error per row' do
    bad_row_attrs = csv_pt_br_row_1.dup
    bad_row_attrs['Data da Resposta'] = nil
    bad_row = instance_double(CSV::Row, to_h: bad_row_attrs)

    allow(CSV).to receive(:foreach)
      .with(file_path, headers: true, col_sep: ';')
      .and_return([bad_row].each)

    result = described_class.call(file_path: file_path)

    expect(result).to include(processed: 1, created: 0, failed: 1, file: file_path)
    expect(result[:duration_ms]).to be_a(Integer)
    expect(result[:errors]).to include(include(line: 2, error: 'response_date missing'))
  end

  it 'returns explicit response_date invalid format error per row' do
    bad_row_attrs = csv_pt_br_row_1.dup
    bad_row_attrs['Data da Resposta'] = '2022-01-20'
    bad_row = instance_double(CSV::Row, to_h: bad_row_attrs)

    allow(CSV).to receive(:foreach)
      .with(file_path, headers: true, col_sep: ';')
      .and_return([bad_row].each)

    result = described_class.call(file_path: file_path)

    expect(result).to include(processed: 1, created: 0, failed: 1, file: file_path)
    expect(result[:duration_ms]).to be_a(Integer)
    expect(result[:errors]).to include(include(line: 2, error: 'response_date invalid (expected DD/MM/YYYY)'))
  end

  it 'adds warnings when likert fields are above 5' do
    allow(CSV).to receive(:foreach)
      .with(file_path, headers: true, col_sep: ';')
      .and_return([row_1].each)

    result = described_class.call(file_path: file_path)

    expect(result[:warnings]).to include(
      include(line: 2, field: :interest_in_role, value: 7, message: 'likert score above 5')
    )
  end

  it 'adds warning when enps is zero' do
    row_with_zero_enps_attrs = csv_pt_br_row_1.dup
    row_with_zero_enps_attrs['eNPS'] = '0'
    row_with_zero_enps = instance_double(CSV::Row, to_h: row_with_zero_enps_attrs)

    allow(CSV).to receive(:foreach)
      .with(file_path, headers: true, col_sep: ';')
      .and_return([row_with_zero_enps].each)

    result = described_class.call(file_path: file_path)

    expect(result[:warnings]).to include(
      include(line: 2, field: :enps, value: 0, message: 'enps score is 0 (strong detractor)')
    )
  end
end
