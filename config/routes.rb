Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  # Disable default Devise user registration ("Sign Up"), but support editing user profile when logged in, which is controlled by Devise's RegistrationsController
  devise_for :users, controllers: { invitations: 'organization_invitations' }, :skip => [:registrations]
    as :user do
      # Since we skip registration above, explicity specify registration routes we need
      get 'users/edit' => 'devise/registrations#edit', as: 'edit_user_registration'
      delete 'users' => 'devise/registrations#destroy', as: 'delete_user'
      # Use custom registrations controller for updating profile
      put 'users' => 'registrations#update', as: 'user_registration'
    end

  root to: 'pages#home'

  get '/documentation/:id', to: 'pages#show', as: :pages
  get '/api', to: 'pages#api'


  get 'contact_emails/confirm/:token', to: 'contact_emails#confirm', as: :contact_email_confirmation

  get '/.well-known/resourcesync', to: 'resourcesync#source_description', as: :resourcesync_source_description, defaults: { format: :xml }
  get '/.well-known/resourcesync/capabilitylist', to: 'resourcesync#capabilitylist', as: :resourcesync_capabilitylist, defaults: { format: :xml }
  get '/.well-known/resourcesync/normalized-capabilitylist/:flavor', to: 'resourcesync#normalized_capabilitylist', as: :resourcesync_normalized_dump_capabilitylist, defaults: { format: :xml }

  get 'dashboard/uploads', to: 'dashboard#uploads', as: :activity
  get 'charts/uploads', to: 'charts#uploads', as: :uploads_chart
  get 'charts/records', to: 'charts#records', as: :records_chart
  
  get '/data', to: 'pages#data'

  # disable default /edit path for organizations in favor of organization_details and provider_details
  resources :organizations, except: [:edit] do
    collection do
      get 'resourcelist', to: 'organizations#index', defaults: { format: :xml }
      get 'normalized_resourcelist/:flavor', to: 'organizations#index', defaults: { normalized: true, format: :xml }, as: :normalized_resourcelist
    end
    member do
      get 'normalized_data'
      get 'processing_status'
      get 'organization_details'
      get 'provider_details'
    end
    resources :marc_records, only: [:index, :show] do
      member do
        get 'marc21'
        get 'marcxml'
      end
    end
    resources :uploads, except: [:update] do
      member do
        get 'info/:attachment_id', to: 'uploads#info', as: :file_info
      end
    end

    # Route in the Manage Organization / View Organization Details tabs
    resources :organization_users, as: 'users', only: [:index, :destroy, :update], path: 'users'
    resources :allowlisted_jwts, only: [:index, :new, :create, :destroy]

    resources :organization_contact_emails, as: 'contact_emails', only: [:new, :create, :destroy]

    get 'invite/new', to: 'organization_invitations#new'
    post 'invite', to: 'organization_invitations#create'
    
    resources :streams, only: [:index, :destroy, :show, :create, :new] do
      collection do
        post 'make_default'
      end

      member do
        get 'profile', to: 'streams#profile'
        post 'reanalyze', to: 'streams#reanalyze'
        get 'resourcelist', to: 'streams#resourcelist', defaults: { format: :xml }
        get 'normalized_resourcelist/:flavor', to: 'streams#normalized_dump', defaults: { format: :xml }, as: :normalized_resourcelist
      end
    end
  end

  get "/file/:id/:filename" => 'proxy#show', as: :proxy_download, constraints: { filename: /.*/ }

  direct :download do |attachment, options|
    route_for(:proxy_download, attachment.id, attachment.filename, options)
  end

  resources :site_users, only: [:index, :update]

  authenticate :user, lambda { |u| u.has_role? :admin } do
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end
end
