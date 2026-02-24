Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs", as: "rswag_ui"
  mount Rswag::Api::Engine => "/api-docs", as: "rswag_api"

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :v1 do
    resources :survey_responses, only: [ :index ]
  end
end
