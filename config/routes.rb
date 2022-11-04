# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :application_credentials
  resources :api_clients do
    get :refresh_token, on: :member, as: :refresh_token
  end

  root 'application_credentials#index'

  match '/:app_id/callback/' => 'application_credentials#generate_access_token', via: %i[get post]
end
