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

  post '/site_admin/become_superadmin', to: 'site_admin#become_superadmin', as: :become_superadmin
  post '/site_admin/disclaim_superadmin', to: 'site_admin#disclaim_superadmin', as: :disclaim_superadmin

  get '/api', to: 'pages#api'
  class OaiConstraint
    def initialize(verb:)
      @verb = verb
    end

    def matches?(request)
      request.params['verb'] == @verb
    end
  end

  get '/oai', to: 'oai#list_records', constraints: OaiConstraint.new(verb: 'ListRecords')
  get '/oai', to: 'oai#list_sets', constraints: OaiConstraint.new(verb: 'ListSets')
  get '/oai', to: 'oai#identify', constraints: OaiConstraint.new(verb: 'Identify')
  get '/oai', to: 'oai#list_metadata_formats', constraints: OaiConstraint.new(verb: 'ListMetadataFormats')
  get '/oai', to: 'oai#bad_verb'

  get 'contact_emails/confirm/:token', to: 'contact_emails#confirm', as: :contact_email_confirmation

  get '/.well-known/resourcesync', to: 'resourcesync#source_description', as: :resourcesync_source_description, defaults: { format: :xml }
  get '/.well-known/resourcesync/capabilitylist', to: 'resourcesync#capabilitylist', as: :resourcesync_capabilitylist, defaults: { format: :xml }
  get '/.well-known/resourcesync/normalized-capabilitylist/:flavor', to: 'resourcesync#normalized_capabilitylist', as: :resourcesync_normalized_dump_capabilitylist, defaults: { format: :xml }

  get 'activity', to: 'activity#index', as: :activity
  get 'activity/normalized_data', to: 'activity#normalized_data'
  get 'activity/uploads', to: 'activity#uploads'
  get 'activity/users', to: 'activity#users'

  get '/data', to: 'pages#data'

  # disable default /edit path for organizations in favor of organization_details and provider_details
  resources :organizations, except: [:edit] do
    collection do
      get 'resourcelist', to: 'organizations#index', defaults: { format: :xml }
      get 'normalized_resourcelist/:flavor', to: 'organizations#index', defaults: { normalized: true, format: :xml }, as: :normalized_resourcelist
    end

    member do
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
      get 'marc_records/:attachment_id', to: 'marc_records#index', as: :attachment_marc_records
    end

    # Route in the Manage Organization / View Organization Details tabs
    resources :organization_users, as: 'users', only: [:index, :destroy, :update], path: 'users'
    resources :allowlisted_jwts, only: [:index, :new, :create, :destroy]

    resource :organization_contact_email, as: 'contact_email', only: [:new, :create, :destroy]

    get 'invite/new', to: 'organization_invitations#new'
    post 'invite', to: 'organization_invitations#create'

    resources :streams, only: [:index, :destroy, :show, :create, :new] do
      collection do
        post 'make_pending_default'
      end

      member do
        get 'normalized_data', to: 'streams#normalized_data'
        get 'processing_status', to: 'streams#processing_status'
        get 'profile', to: 'streams#profile'
        post 'reanalyze', to: 'streams#reanalyze'
        get 'resourcelist', to: 'streams#resourcelist', defaults: { format: :xml }
        get 'normalized_resourcelist/:flavor', to: 'streams#normalized_dump', defaults: { format: :xml }, as: :normalized_resourcelist
      end

      get 'marc_records', to: 'marc_records#index'
    end
  end

  get "/file/:id/:filename" => 'proxy#show', as: :proxy_download, constraints: { filename: /.*/ }

  direct :download do |attachment, options|
    route_for(:proxy_download, attachment.id, attachment.filename, options)
  end

  resources :groups
  resources :site_users, only: [:index, :update]

  authenticate :user, lambda { |u| u.has_role? :admin } do
    mount MissionControl::Jobs::Engine, at: "/jobs", as: 'jobs'
  end
end
