Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  devise_for :users, controllers: { invitations: 'organization_invitations' }

  root to: 'pages#home'
  get '/api', to: 'pages#api'

  get 'contact_emails/confirm/:token', to: 'contact_emails#confirm', as: :contact_email_confirmation

  resources :organizations do
    resources :uploads
    resources :organization_users, as: 'users', only: :destroy
    resources :organization_contact_emails, as: 'contact_emails', only: [:new, :create, :destroy]

    get 'invite/new', to: 'organization_invitations#new'
    post 'invite', to: 'organization_invitations#create'
    resources :allowlisted_jwts, only: [:index, :create, :destroy]
  end

  get "/file/:id/:filename" => 'proxy#show', as: :proxy_download

  direct :download do |blob, options|
    route_for(:proxy_download, blob.id, blob.filename, options)
  end

  resources :site_users, only: [:index, :update]

  authenticate :user, lambda { |u| u.has_role? :admin } do
    require 'sidekiq/web'
    Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]
    mount Sidekiq::Web => '/sidekiq'
  end
end
