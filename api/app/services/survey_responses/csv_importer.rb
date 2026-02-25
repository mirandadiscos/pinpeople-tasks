require 'csv'

module SurveyResponses
  class CsvImporter
    MISSING_RESPONSE_DATE_MESSAGE = 'response_date missing'.freeze
    INVALID_RESPONSE_DATE_MESSAGE = 'response_date invalid (expected DD/MM/YYYY)'.freeze
    LIKERT_WARNING_THRESHOLD = 5
    LIKERT_FIELDS = %i[
      interest_in_role
      contribution
      learning_and_development
      feedback
      manager_interaction
      career_clarity
      permanence_expectation
    ].freeze

    class << self
      def call(file_path:)
        new(file_path:).call
      end
    end

    def initialize(file_path:)
      @file_path = file_path
    end

    def call
      started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      result = {
        processed: 0,
        created: 0,
        failed: 0,
        file: file_path,
        errors: [],
        warnings: []
      }

      Rails.logger.info("event=survey_response_import_started file=#{file_path}")
      CSV.foreach(file_path, headers: true, col_sep: ';').with_index(2) do |row, line|
        result[:processed] += 1

        begin
          normalized_attrs = normalize_row(row.to_h)
          append_likert_warnings(result: result, attrs: normalized_attrs, line: line)
          append_enps_zero_warning(result: result, attrs: normalized_attrs, line: line)
          SurveyResponse.create!(normalized_attrs)
          result[:created] += 1
        rescue StandardError => e
          result[:failed] += 1
          result[:errors] << { line: line, error: e.message }
          Rails.logger.info("event=survey_response_import_row_failed file=#{file_path} line=#{line} error=\"#{e.message}\"")
        end
      end

      duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000).round
      result[:duration_ms] = duration_ms
      Rails.logger.info(
        "event=survey_response_import_completed file=#{file_path} " \
        "processed=#{result[:processed]} created=#{result[:created]} failed=#{result[:failed]} " \
        "warnings=#{result[:warnings].size} duration_ms=#{duration_ms}"
      )

      result
    end

    private

    attr_reader :file_path

    def normalize_row(attrs)
      {
        name: attrs['nome'],
        email: attrs['email'],
        corporate_email: attrs['email_corporativo'],
        department: attrs['area'],
        role: attrs['cargo'],
        job_function: attrs['funcao'],
        location: attrs['localidade'],
        company_tenure: attrs['tempo_de_empresa'],
        gender: attrs['genero'],
        generation: attrs['geracao'],
        level_0_company: attrs['n0_empresa'],
        level_1_board: attrs['n1_diretoria'],
        level_2_management: attrs['n2_gerencia'],
        level_3_coordination: attrs['n3_coordenacao'],
        level_4_area: attrs['n4_area'],
        response_date: parse_response_date(attrs['Data da Resposta']),
        interest_in_role: to_int(attrs['Interesse no Cargo']),
        interest_in_role_comment: normalize_comment(attrs['Comentários - Interesse no Cargo']),
        contribution: to_int(attrs['Contribuição']),
        contribution_comment: normalize_comment(attrs['Comentários - Contribuição']),
        learning_and_development: to_int(attrs['Aprendizado e Desenvolvimento']),
        learning_and_development_comment: normalize_comment(attrs['Comentários - Aprendizado e Desenvolvimento']),
        feedback: to_int(attrs['Feedback']),
        feedback_comment: normalize_comment(attrs['Comentários - Feedback']),
        manager_interaction: to_int(attrs['Interação com Gestor']),
        manager_interaction_comment: normalize_comment(attrs['Comentários - Interação com Gestor']),
        career_clarity: to_int(attrs['Clareza sobre Possibilidades de Carreira']),
        career_clarity_comment: normalize_comment(attrs['Comentários - Clareza sobre Possibilidades de Carreira']),
        permanence_expectation: to_int(attrs['Expectativa de Permanência']),
        permanence_expectation_comment: normalize_comment(attrs['Comentários - Expectativa de Permanência']),
        enps: parse_enps(attrs['eNPS']),
        enps_comment: normalize_comment(attrs['[Aberta] eNPS'])
      }
    end

    def parse_response_date(value)
      parsed = value.to_s.strip
      raise ArgumentError, MISSING_RESPONSE_DATE_MESSAGE if parsed.empty?

      begin
        Date.strptime(parsed, '%d/%m/%Y')
      rescue Date::Error, ArgumentError
        raise ArgumentError, INVALID_RESPONSE_DATE_MESSAGE
      end
    end

    def to_int(value)
      value.to_i
    end

    def parse_enps(value)
      parsed = value.to_s.strip
      return nil if parsed.empty?

      Integer(parsed, 10)
    rescue ArgumentError
      raise ArgumentError, 'enps invalid (expected integer 0..10)'
    end

    def normalize_comment(value)
      normalized = value.to_s
      stripped = normalized.strip

      return nil if stripped.empty?
      return nil if stripped == '-'

      value
    end

    def append_likert_warnings(result:, attrs:, line:)
      LIKERT_FIELDS.each do |field|
        value = attrs[field].to_i
        next unless value > LIKERT_WARNING_THRESHOLD

        warning = {
          line: line,
          field: field,
          value: value,
          message: "likert score above #{LIKERT_WARNING_THRESHOLD}"
        }
        result[:warnings] << warning
        Rails.logger.info(
          "event=survey_response_import_row_warning file=#{file_path} line=#{line} " \
          "field=#{field} value=#{value} message=\"#{warning[:message]}\""
        )
      end
    end

    def append_enps_zero_warning(result:, attrs:, line:)
      return unless attrs[:enps] == 0

      warning = {
        line: line,
        field: :enps,
        value: 0,
        message: "enps score is 0 (strong detractor)"
      }
      result[:warnings] << warning
      Rails.logger.info(
        "event=survey_response_import_row_warning file=#{file_path} line=#{line} " \
        "field=enps value=0 message=\"#{warning[:message]}\""
      )
    end
  end
end
