Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"

  resources :job_applications do
    resources :notes, only: %i[create destroy]
  end
  resources :companies
end
