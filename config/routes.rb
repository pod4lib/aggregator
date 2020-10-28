Rails.application.routes.draw do
  namespace :admin do
      resources :users
      resources :allowlisted_jwts
      resources :streams
      resources :roles
      resources :organizations
      resources :batches
      resources :uploads

      root to: "users#index"
    end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  devise_for :users

  root to: 'pages#home'

  resources :organizations
end
