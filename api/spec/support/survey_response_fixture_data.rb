module SurveyResponseFixtureData
  def csv_pt_br_row_1
    {
      'nome' => 'Demo 001',
      'email' => 'demo001@pinpeople.com.br',
      'email_corporativo' => 'demo001@pinpeople.com.br',
      'area' => 'administrativo',
      'cargo' => 'estagiário',
      'funcao' => 'profissional',
      'localidade' => 'brasília',
      'tempo_de_empresa' => 'entre 1 e 2 anos',
      'genero' => 'masculino',
      'geracao' => 'geração z',
      'n0_empresa' => 'empresa',
      'n1_diretoria' => 'diretoria a',
      'n2_gerencia' => 'gerência a1',
      'n3_coordenacao' => 'coordenação a11',
      'n4_area' => 'área a112',
      'Data da Resposta' => '20/01/2022',
      'Interesse no Cargo' => '7',
      'Comentários - Interesse no Cargo' => '-',
      'Contribuição' => '1',
      'Comentários - Contribuição' => '-',
      'Aprendizado e Desenvolvimento' => '6',
      'Comentários - Aprendizado e Desenvolvimento' => '-',
      'Feedback' => '5',
      'Comentários - Feedback' => '-',
      'Interação com Gestor' => '6',
      'Comentários - Interação com Gestor' => '-',
      'Clareza sobre Possibilidades de Carreira' => '4',
      'Comentários - Clareza sobre Possibilidades de Carreira' => '-',
      'Expectativa de Permanência' => '2',
      'Comentários - Expectativa de Permanência' => '-',
      'eNPS' => '5',
      '[Aberta] eNPS' => 'Excelente ambiente'
    }
  end

  def csv_pt_br_row_2
    {
      'nome' => 'Demo 002',
      'email' => 'demo002@pinpeople.com.br',
      'email_corporativo' => 'demo002@pinpeople.com.br',
      'area' => 'comercial',
      'cargo' => 'analista',
      'funcao' => 'profissional',
      'localidade' => 'recife',
      'tempo_de_empresa' => 'menos de 1 ano',
      'genero' => 'feminino',
      'geracao' => 'geração z',
      'n0_empresa' => 'empresa',
      'n1_diretoria' => 'diretoria a',
      'n2_gerencia' => 'gerência a1',
      'n3_coordenacao' => 'coordenação a11',
      'n4_area' => 'área a111',
      'Data da Resposta' => '20/01/2022',
      'Interesse no Cargo' => '6',
      'Comentários - Interesse no Cargo' => '-',
      'Contribuição' => '5',
      'Comentários - Contribuição' => 'Gostaria de liderar iniciativas que agreguem valor.',
      'Aprendizado e Desenvolvimento' => '4',
      'Comentários - Aprendizado e Desenvolvimento' => '-',
      'Feedback' => '6',
      'Comentários - Feedback' => '-',
      'Interação com Gestor' => '5',
      'Comentários - Interação com Gestor' => 'Meu gestor é acessível e apoia minha carreira.',
      'Clareza sobre Possibilidades de Carreira' => '3',
      'Comentários - Clareza sobre Possibilidades de Carreira' => '-',
      'Expectativa de Permanência' => '4',
      'Comentários - Expectativa de Permanência' => '-',
      'eNPS' => '8',
      '[Aberta] eNPS' => 'Sinto falta de mais oportunidades de crescimento profissional.'
    }
  end

  def csv_pt_br_headers
    csv_pt_br_row_1.keys
  end

  def normalized_db_attrs_row_1
    {
      name: 'Demo 001',
      email: 'demo001@pinpeople.com.br',
      corporate_email: 'demo001@pinpeople.com.br',
      department: 'administrativo',
      role: 'estagiário',
      job_function: 'profissional',
      location: 'brasília',
      company_tenure: 'entre 1 e 2 anos',
      gender: 'masculino',
      generation: 'geração z',
      level_0_company: 'empresa',
      level_1_board: 'diretoria a',
      level_2_management: 'gerência a1',
      level_3_coordination: 'coordenação a11',
      level_4_area: 'área a112',
      response_date: Date.new(2022, 1, 20),
      interest_in_role: 7,
      interest_in_role_comment: nil,
      contribution: 1,
      contribution_comment: nil,
      learning_and_development: 6,
      learning_and_development_comment: nil,
      feedback: 5,
      feedback_comment: nil,
      manager_interaction: 6,
      manager_interaction_comment: nil,
      career_clarity: 4,
      career_clarity_comment: nil,
      permanence_expectation: 2,
      permanence_expectation_comment: nil,
      enps: 5,
      enps_comment: 'Excelente ambiente'
    }
  end

  def normalized_db_attrs_row_2
    {
      name: 'Demo 002',
      email: 'demo002@pinpeople.com.br',
      corporate_email: 'demo002@pinpeople.com.br',
      department: 'comercial',
      role: 'analista',
      job_function: 'profissional',
      location: 'recife',
      company_tenure: 'menos de 1 ano',
      gender: 'feminino',
      generation: 'geração z',
      level_0_company: 'empresa',
      level_1_board: 'diretoria a',
      level_2_management: 'gerência a1',
      level_3_coordination: 'coordenação a11',
      level_4_area: 'área a111',
      response_date: Date.new(2022, 1, 20),
      interest_in_role: 6,
      interest_in_role_comment: nil,
      contribution: 5,
      contribution_comment: 'Gostaria de liderar iniciativas que agreguem valor.',
      learning_and_development: 4,
      learning_and_development_comment: nil,
      feedback: 6,
      feedback_comment: nil,
      manager_interaction: 5,
      manager_interaction_comment: 'Meu gestor é acessível e apoia minha carreira.',
      career_clarity: 3,
      career_clarity_comment: nil,
      permanence_expectation: 4,
      permanence_expectation_comment: nil,
      enps: 8,
      enps_comment: 'Sinto falta de mais oportunidades de crescimento profissional.'
    }
  end

  def api_response_attrs_row_1
    serialize_db_attrs_for_api(normalized_db_attrs_row_1)
  end

  def api_response_attrs_row_2
    serialize_db_attrs_for_api(normalized_db_attrs_row_2)
  end

  def serialize_db_attrs_for_api(attrs)
    attrs.merge(response_date: attrs[:response_date].iso8601)
  end
end

RSpec.configure do |config|
  config.include SurveyResponseFixtureData
end
