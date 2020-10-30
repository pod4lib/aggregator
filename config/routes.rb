Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  devise_for :users

  root to: 'pages#home'
  get '/api', to: 'pages#api'

  resources :organizations do
    resources :uploads
    resources :allowlisted_jwts, only: [:index, :create, :destroy]
  end

  get "/file/:id/:filename" => 'proxy#show', as: :proxy_download

  direct :download do |blob, options|
    route_for(:proxy_download, blob.id, blob.filename, options)
  end
end
