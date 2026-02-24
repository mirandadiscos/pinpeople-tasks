# API - Tech Playground

## Como Ler Este README

- `Setup`: bootstrap local do projeto.
- `Seguranca`: variaveis de ambiente, auth e CORS.
- `Endpoint /v1/survey_responses`: contrato de filtros e paginacao.
- `Swagger / API Docs`: como gerar e abrir documentacao.
- `Tasks e Criterio de Conclusao`: qual task rodar e quando considerar concluida.
- `Assumptions`: premissas do CSV e escolhas de modelagem.

## Rastreabilidade por Task (Challenge)

Esta API cobre explicitamente as Tasks `1`, `3` e `9` do README raiz de `tech_playground`.

- `Task 1 - Create a Basic Database`
  - objetivo desta entrega:
    - importar o `data.csv` para PostgreSQL com normalizacao de campos
  - onde esta documentado:
    - `Setup` (preparacao de banco)
    - `Task 1 - Importar CSV`
    - `Assumptions do data.csv`
    - `Estrategia de Indices (PostgreSQL)`

- `Task 3 - Create a Test Suite`
  - objetivo desta entrega:
    - suite de testes com RSpec e cobertura com SimpleCov
  - onde esta documentado:
    - `Setup > Rodar testes`
    - `Policy de cobertura` (SimpleCov >= 90%)
    - `Task 3 - Suite de Testes`
    - `Swagger / API Docs` (geracao da documentacao via rswag)

- `Task 9 - Build a Simple API`
  - objetivo desta entrega:
    - API `v1/survey_responses` com filtros, paginacao e seguranca minima
  - onde esta documentado:
    - `Setup` (subir projeto)
    - `Seguranca Minima (Baseline)` (Bearer token + CORS)
    - `Endpoint /v1/survey_responses`
    - `Task 9 - Rodar e testar API`
    - `Swagger / API Docs`

## Setup

### Requisitos

- Ruby `3.4.7` (ver `./.ruby-version`)
- PostgreSQL rodando localmente
- Bundler

### 1. Instalar dependencias

```bash
cd api
bundle install
```

### 2. Configurar ambiente local

```bash
cp .env.example .env
```

Variaveis de banco no `.env` (Rails/PostgreSQL):

- `API_DB_HOST` (ex.: `127.0.0.1`)
- `API_DB_PORT` (ex.: `5432`)
- `API_DB_USERNAME` (ex.: `postgres`)
- `API_DB_PASSWORD`
- `API_DB_NAME_DEVELOPMENT` (ex.: `api_development`)
- `API_DB_NAME_TEST` (ex.: `api_test`)
- `API_DB_NAME_PRODUCTION` (ex.: `api_production`)

### 3. Preparar banco

```bash
bin/rails db:prepare
```

### 4. Importar dados(Task 1)
```bash
bundle exec rake importer_csv:survey_response
```

Relatorio final do import:

- `failed` indica linhas rejeitadas (erro de validacao/parse).
- `warnings` indica linhas importadas com alertas de qualidade de dado, por exemplo:
  - campos Likert acima de `5`
  - `eNPS = 0` (detrator extremo)

### 5. Subir API localmente

```bash
bin/dev
```

API local: `http://127.0.0.1:3000`.

### 6. Rodar testes

```bash
bundle exec rspec
```

Policy de cobertura:

- SimpleCov com cobertura minima global de `90%`.
- Se a cobertura ficar abaixo de `90%`, o comando de testes falha.

## Seguranca Minima

### Variaveis de ambiente

- `API_AUTH_TOKEN`: token Bearer para endpoints protegidos.
- `CORS_ALLOWED_ORIGINS`: lista separada por virgula com origens permitidas.
  - Exemplo: `http://localhost:3000,https://app.example.com`
- `SWAGGER_SERVER_URL`: URL base usada na secao `servers` do OpenAPI.
  - Exemplo: `http://127.0.0.1:3000`

Com `dotenv-rails`, o `.env` e carregado automaticamente em desenvolvimento/teste.

### Endpoints publicos (sem token)

- `/up`
- `/api-docs`

### Exemplo autenticado

```bash
curl -H "Authorization: Bearer $API_AUTH_TOKEN" http://127.0.0.1:3000/v1/survey_responses
```

## Endpoint `/v1/survey_responses`

### Query params de data

- `date=YYYY-MM-DD`: filtro por data exata.
- `from=YYYY-MM-DD&to=YYYY-MM-DD`: range inclusivo.
- `from` sozinho: range aberto de `from` ate o futuro.
- `to` sozinho: range aberto do passado ate `to`.
- `date` nao pode ser combinado com `from`/`to` (retorna `422`).

### Paginacao

- `page` (default: `1`)
- `per_page` (default: `25`, maximo: `100`)

## Decisao Arquitetural e Desacoplamento

Para manter a API em padrao Rails com menor acoplamento, a stack de `v1/survey_responses` foi separada por responsabilidade:

- `Controller` (`V1::SurveyResponsesController`): apenas orquestra request/response HTTP.
- `Service` (`SurveyResponses::Index::Service`): executa o caso de uso e monta `data` + `meta`.
- `Contract` (`SurveyResponses::Index::Contract`): valida filtros de `index` com `dry-validation`.
- `Query Object` (`SurveyResponses::Index::Query`): concentra composicao de consulta no ActiveRecord.
- `Serializer` (`SurveyResponseSerializer`): define contrato de saida JSON do recurso.
- `Authenticator` (`ApiTokenAuthenticator`): isola regra de autenticacao Bearer token.

Beneficios praticos dessa decisao:

- reduz logica de negocio no controller;
- melhora testabilidade unitária por camada;
- facilita evoluir regras de filtro/serializacao sem quebrar endpoint;
- evita duplicacao de regra HTTP e de dominio.

### Observacao sobre status HTTP 422 no Rails 8/Rack 3

- A API retorna `422` para erros de validacao/filtro, com `error.code = \"unprocessable_content\"` no payload.
- No codigo Rails, usamos `:unprocessable_content` para evitar warning deprecado do Rack.
- Isso preserva o mesmo comportamento HTTP externo (`422`) com semantica consistente entre payload e status interno.

## Swagger / API Docs

### Gerar OpenAPI

```bash
bundle exec rake rswag:specs:swaggerize
```

Observacao: essa task usa RSpec no ambiente de teste; o banco de teste precisa estar disponivel.

### Abrir docs

1. Subir API:

```bash
bin/dev
```

2. Acessar:

- UI: `http://127.0.0.1:3000/api-docs`
- YAML: `http://127.0.0.1:3000/api-docs/v1/swagger.yaml`

### Task 1 - Importar CSV

Comando:

```bash
bundle exec rake importer_csv:survey_response
```

### Task 3 - Suite de Testes

Rodar testes:

```bash
bundle exec rspec
```

- SimpleCov reporta cobertura minima global de `90%` (gate configurado no projeto)

Conferir cobertura:

- arquivo HTML: `coverage/index.html`

Gerar contrato OpenAPI via testes (rswag):

```bash
bundle exec rake rswag:specs:swaggerize
```

- arquivo `swagger/v1/swagger.yaml` e gerado/atualizado

### Task 9 - Rodar e testar API

Subir API:

```bash
bin/dev
```

- endpoint responde autenticado com Bearer token

Testar via Swagger:

- `http://127.0.0.1:3000/api-docs/index.html`

Testar manualmente via collections:

- arquivo: `../collections/api.http`

## Assumptions do `data.csv`

- Separador: `;`
- Header presente na primeira linha
- Codificacao: UTF-8
- Datas no formato `dd/mm/yyyy` (ex.: `20/01/2022`)
- Colunas de comentario podem vir como `-` para ausencia de texto

## Observacao Importante - Escala Likert

- Campos Likert validam em `1..7` (conforme `data.csv`).
- Campo `eNPS` valida em `0..10`.
- Ha divergencia com documento do challenge (menciona `1..5`).
- Recomendado alinhar com stakeholders:
  - manter `1..7` e atualizar documentacao, ou
  - migrar para `1..5` com plano de transicao.

## Estrategia de Indices (PostgreSQL)

- Adicionar indices com base em consulta real (`EXPLAIN ANALYZE`, `pg_stat_statements`).
- Contexto atual:
  - indice em `response_date`
  - indice/constraint unico: `UNIQUE (corporate_email, response_date)`
- No `data.csv` atual nao foram identificados duplicados nessa combinacao.
- Regra final de unicidade deve ser alinhada com stakeholders.
