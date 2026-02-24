namespace :importer_csv do
  desc 'Import survey responses from CSV'
  task survey_response: :environment do
    result = SurveyResponses::CsvImporter.call(file_path: '../data.csv')

    puts "Import completed | file=#{result[:file]} | processed=#{result[:processed]} | created=#{result[:created]} | failed=#{result[:failed]} | warnings=#{result[:warnings].size} | duration_ms=#{result[:duration_ms]}"

    if result[:warnings].any?
      puts 'Import warnings:'
      result[:warnings].each do |warning|
        puts "- line=#{warning[:line]} | field=#{warning[:field]} | value=#{warning[:value]} | message=\"#{warning[:message]}\""
      end
    end

    if result[:failed].positive?
      puts 'Import errors:'
      result[:errors].each do |error|
        puts "- line=#{error[:line]} | message=\"#{error[:error]}\""
      end

      exit 1
    end
  end
end
