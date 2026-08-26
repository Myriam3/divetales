Rails.application.routes.draw do
  mount RailsIcons::Engine, at: '/rails_icons'
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :trips, only: [:index, :show, :new, :create, :destroy, :edit, :update] do
    resources :dives, only: [:index, :show, :new, :create]
  end
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get "/identification", to: "identifications#index"
  post "/identification", to: "identifications#create"
  get "/identification/details", to: "identifications#details", as: :identification_details
  get "/identification/confirm", to: "identifications#confirm"
  post "/identification/save", to: "identifications#save"
  post "/identification/retry", to: "identifications#retry", as: :identification_retry
  # Defines the root path route ("/")
  # root "posts#index"
  #
  resources :pictures do
    resources :dives, only: [:create]

    collection do
      get :dives_for_trip
      post :bulk_create
      delete :bulk_destroy
    end

    member do
      get :generate_species_details
    end
  end

  resources :dives, only: [:index, :show, :destroy]

  resources :dive_sites, only: [:index]

  get "api/mapbox", to: "api#mapbox"

  authenticate :user, ->(user) { user.admin? } do
    mount MissionControl::Jobs::Engine, at: "/jobs"
  end
end
