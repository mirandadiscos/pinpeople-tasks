require 'swagger_helper'

RSpec.describe 'v1/survey_responses', type: :request do
  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('API_AUTH_TOKEN').and_return('test-api-token')
  end

  def parsed_json(response)
    JSON.parse(response.body, symbolize_names: true)
  end

  path '/v1/survey_responses' do
    get('List survey responses') do
      tags 'Survey Responses'
      security [ bearerAuth: [] ]
      produces 'application/json'

      parameter name: :Authorization, in: :header, schema: { type: :string }, required: true
      parameter name: :page, in: :query, schema: { type: :integer, minimum: 1 }, required: false
      parameter name: :per_page, in: :query, schema: { type: :integer, minimum: 1, maximum: 100 }, required: false
      parameter name: :date, in: :query, schema: { type: :string, format: :date }, required: false
      parameter name: :from, in: :query, schema: { type: :string, format: :date }, required: false
      parameter name: :to, in: :query, schema: { type: :string, format: :date }, required: false

      let(:Authorization) { 'Bearer test-api-token' }
      let(:page) { nil }
      let(:per_page) { nil }
      let(:date) { nil }
      let(:from) { nil }
      let(:to) { nil }

      let!(:response_1) do
        SurveyResponse.create!(
          normalized_db_attrs_row_1.merge(
            email: 'request001@pinpeople.com.br',
            corporate_email: 'request001@pinpeople.com.br',
            response_date: Date.new(2022, 1, 20)
          )
        )
      end

      let!(:response_2) do
        SurveyResponse.create!(
          normalized_db_attrs_row_2.merge(
            email: 'request002@pinpeople.com.br',
            corporate_email: 'request002@pinpeople.com.br',
            response_date: Date.new(2022, 1, 21)
          )
        )
      end

      let!(:response_3) do
        SurveyResponse.create!(
          normalized_db_attrs_row_2.merge(
            email: 'request003@pinpeople.com.br',
            corporate_email: 'request003@pinpeople.com.br',
            response_date: Date.new(2022, 1, 22)
          )
        )
      end

      response(200, 'successful') do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  name: { type: :string },
                  email: { type: :string, format: :email },
                  corporate_email: { type: :string, format: :email },
                  department: { type: :string },
                  role: { type: :string },
                  job_function: { type: :string },
                  location: { type: :string },
                  company_tenure: { type: :string },
                  gender: { type: :string },
                  generation: { type: :string },
                  level_0_company: { type: :string },
                  level_1_board: { type: :string },
                  level_2_management: { type: :string },
                  level_3_coordination: { type: :string },
                  level_4_area: { type: :string },
                  response_date: { type: :string, format: :date },
                  interest_in_role: { type: :integer },
                  interest_in_role_comment: { type: :string, nullable: true },
                  contribution: { type: :integer },
                  contribution_comment: { type: :string, nullable: true },
                  learning_and_development: { type: :integer },
                  learning_and_development_comment: { type: :string, nullable: true },
                  feedback: { type: :integer },
                  feedback_comment: { type: :string, nullable: true },
                  manager_interaction: { type: :integer },
                  manager_interaction_comment: { type: :string, nullable: true },
                  career_clarity: { type: :integer },
                  career_clarity_comment: { type: :string, nullable: true },
                  permanence_expectation: { type: :integer },
                  permanence_expectation_comment: { type: :string, nullable: true },
                  enps: { type: :integer },
                  enps_comment: { type: :string, nullable: true }
                }
              }
            },
            meta: {
              type: :object,
              properties: {
                page: { type: :integer },
                per_page: { type: :integer },
                total_count: { type: :integer },
                total_pages: { type: :integer },
                filters: {
                  type: :object,
                  properties: {
                    date: { type: :string, format: :date, nullable: true },
                    from: { type: :string, format: :date, nullable: true },
                    to: { type: :string, format: :date, nullable: true }
                  }
                }
              }
            }
          },
          required: %w[data meta]

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: parsed_json(response)
            }
          }
        end

        run_test! do |response|
          body = parsed_json(response)

          aggregate_failures do
            expect(body[:data].size).to eq(3)
            expect(body[:data].first[:response_date]).to eq('2022-01-20')
            expect(body[:meta]).to include(page: 1, per_page: 25, total_count: 3, total_pages: 1)
            expect(body[:meta][:filters]).to include(date: nil, from: nil, to: nil)
          end
        end
      end

      response(200, 'successful with date filter') do
        let(:date) { '2022-01-20' }

        run_test! do |response|
          body = parsed_json(response)

          aggregate_failures do
            expect(body[:data].size).to eq(1)
            expect(body[:data].first[:response_date]).to eq('2022-01-20')
            expect(body[:meta][:filters]).to include(date: '2022-01-20', from: nil, to: nil)
          end
        end
      end

      response(200, 'successful with pagination') do
        let(:page) { 2 }
        let(:per_page) { 1 }

        run_test! do |response|
          body = parsed_json(response)

          aggregate_failures do
            expect(body[:data].size).to eq(1)
            expect(body[:data].first[:response_date]).to eq('2022-01-21')
            expect(body[:meta]).to include(page: 2, per_page: 1, total_count: 3, total_pages: 3)
          end
        end
      end

      response(422, 'invalid when mixing date and range') do
        let(:date) { '2022-01-20' }
        let(:from) { '2022-01-01' }
        let(:to) { '2022-01-31' }

        schema type: :object,
          properties: {
            error: {
              type: :object,
              properties: {
                code: { type: :string },
                message: { type: :string }
              },
              required: %w[code message]
            }
          },
          required: ['error']

        run_test! do |response|
          body = parsed_json(response)

          expect(body).to include(
            error: { code: 'unprocessable_entity', message: 'Use date or from/to, not both' }
          )
        end
      end
    end
  end
end
