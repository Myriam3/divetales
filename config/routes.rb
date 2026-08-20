Rails.application.routes.draw do
  mount RailsIcons::Engine, at: '/rails_icons'
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :trips, only: [:index, :show, :new, :create] do
    resources :dives, only: [:index, :new, :create]
  end
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get "/identification", to: "identifications#index"
  post "/identification", to: "identifications#create"
  get "/identification/details", to: "identifications#details", as: :identification_details
  get "/identification/confirm", to: "identifications#confirm"
  post "/identification/save", to: "identifications#save"
  # Defines the root path route ("/")
  # root "posts#index"
  #
  resources :pictures do
    resources :dives, only: [:create]

    collection do
      get :dives_for_trip
      post :bulk_create
    end
  end

  get "/dives", to: "dives#index", as: "dives"
  get "/dives/new", to: "dives#new", as: "new_dive"
  post "/dives", to: "dives#create"
  get "/dives/:id", to: "dives#show", as: "dive"
  delete "/dives/:id", to: "dives#destroy"
end
