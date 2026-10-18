Rails.application.routes.draw do
  resource :session, only: %i[new create destroy]
  resources :passwords, param: :token, only: %i[new create edit update]
  get "sign-up", to: "registrations#new", as: :new_registration
  post "sign-up", to: "registrations#create", as: :registration
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"
  get "follow_ups", to: "dashboard#follow_ups", as: :follow_ups

  resources :job_applications do
    get :pipeline, on: :collection
    post :duplicate, on: :member
    patch :complete_follow_up, on: :member
    resources :notes, only: %i[create destroy]
  end
  resources :companies
end
