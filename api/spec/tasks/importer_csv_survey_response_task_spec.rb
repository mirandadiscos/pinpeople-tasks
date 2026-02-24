require 'rails_helper'
require 'rake'

RSpec.describe 'importer_csv:survey_response' do
  let(:task_name) { 'importer_csv:survey_response' }
  let(:task) { Rake::Task[task_name] }

  before(:all) do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
  end

  before do
    task.reenable
  end

  it 'delegates import execution to SurveyResponses::CsvImporter and prints success summary' do
    allow(SurveyResponses::CsvImporter).to receive(:call).and_return(
      processed: 2,
      created: 2,
      failed: 0,
      file: '../data.csv',
      duration_ms: 12,
      warnings: [],
      errors: []
    )

    expect { task.invoke }.to output(
      "Import completed | file=../data.csv | processed=2 | created=2 | failed=0 | warnings=0 | duration_ms=12\n"
    ).to_stdout

    expect(SurveyResponses::CsvImporter).to have_received(:call).with(file_path: '../data.csv')
  end

  it 'prints failures and exits with status 1 when any row fails' do
    allow(SurveyResponses::CsvImporter).to receive(:call).and_return(
      processed: 2,
      created: 1,
      failed: 1,
      file: '../data.csv',
      duration_ms: 23,
      warnings: [],
      errors: [ { line: 3, error: 'response_date missing' } ]
    )

    expect do
      expect { task.invoke }.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end.to output(
      "Import completed | file=../data.csv | processed=2 | created=1 | failed=1 | warnings=0 | duration_ms=23\n" \
      "Import errors:\n" \
      "- line=3 | message=\"response_date missing\"\n"
    ).to_stdout
  end

  it 'prints warnings when importer returns warning entries' do
    allow(SurveyResponses::CsvImporter).to receive(:call).and_return(
      processed: 1,
      created: 1,
      failed: 0,
      file: '../data.csv',
      duration_ms: 7,
      warnings: [ { line: 10, field: :enps, value: 0, message: 'enps score is 0 (strong detractor)' } ],
      errors: []
    )

    expect { task.invoke }.to output(
      "Import completed | file=../data.csv | processed=1 | created=1 | failed=0 | warnings=1 | duration_ms=7\n" \
      "Import warnings:\n" \
      "- line=10 | field=enps | value=0 | message=\"enps score is 0 (strong detractor)\"\n"
    ).to_stdout
  end
end
