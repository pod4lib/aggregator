Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  devise_for :users, controllers: { invitations: 'organization_invitations', registrations: 'registrations' }

  root to: 'pages#home'
  get '/api', to: 'pages#api'

  get 'contact_emails/confirm/:token', to: 'contact_emails#confirm', as: :contact_email_confirmation

  get '/.well-known/resourcesync', to: 'resourcesync#source_description', as: :resourcesync_source_description, defaults: { format: :xml }
  get '/.well-known/resourcesync/capabilitylist', to: 'resourcesync#capabilitylist', as: :resourcesync_capabilitylist, defaults: { format: :xml }

  get 'dashboard/uploads', to: 'dashboard#uploads', as: :activity
  get 'charts/uploads', to: 'charts#uploads', as: :uploads_chart
  get 'charts/records', to: 'charts#records', as: :records_chart

  resources :organizations do
    collection do
      get 'resourcelist', to: 'organizations#index', defaults: { format: :xml }
    end
    resources :uploads
    resources :organization_users, as: 'users', only: :destroy
    resources :organization_contact_emails, as: 'contact_emails', only: [:new, :create, :destroy]

    get 'invite/new', to: 'organization_invitations#new'
    post 'invite', to: 'organization_invitations#create'
    resources :allowlisted_jwts, only: [:index, :create, :destroy]
    resources :streams, only: [:index, :destroy, :show, :create, :new] do
      collection do
        post 'make_default'
      end

      member do
        get 'resourcelist', to: 'streams#show', defaults: { format: :xml }
        get :removed_since_previous_stream
      end
    end
  end

  get "/file/:id/:filename" => 'proxy#show', as: :proxy_download, constraints: { filename: /.*/ }

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
