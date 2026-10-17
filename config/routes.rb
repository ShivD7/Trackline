Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"
  get "follow_ups", to: "dashboard#follow_ups", as: :follow_ups

  resources :job_applications do
    get :pipeline, on: :collection
    post :duplicate, on: :member
    resources :notes, only: %i[create destroy]
  end
  resources :companies
end
