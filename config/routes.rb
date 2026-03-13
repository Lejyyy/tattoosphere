Rails.application.routes.draw do
  # ================================
  # PAGES & SEARCH
  # ================================
  root "pages#home"
  get "/dashboard", to: "dashboard#show", as: :dashboard
  get "/map",    to: "pages#map",    as: :map
  get "/search", to: "searches#index", as: :search

  # ================================
  # AUTHENTIFICATION
  # ================================
  devise_for :users, controllers: { registrations: "registrations" }

  # ================================
  # SHOPS
  # ================================
  resources :shops do
    resource  :favorite, only: [ :create, :destroy ]
    resources :bookings,  only: [ :new, :create ]
    resources :events,    only: [ :index, :show ]
    resources :medias,    only: [ :index ]
    resources :socials,   only: [ :index ]
    member do
      post   :add_tatoueur
      delete :remove_tatoueur
    end
  end

  # ================================
  # TATOUEURS
  # ================================
  resources :tatoueurs do
    resource  :favorite, only: [ :create, :destroy ]
    resources :portfolios do
      resource  :favorite, only: [ :create, :destroy ]
      resources :portfolio_items do
        resource :favorite, only: [ :create, :destroy ]
      end
    end
    resources :availabilities, only: [ :index, :create, :destroy ]
    resources :reviews,        only: [ :index ]
    resources :events,         only: [ :index, :show ]
    resources :medias,         only: [ :index ]
    resources :socials,        only: [ :index ]
    member do
      get  :verification
      post :submit_verification
    end
  end

  # ================================
  # BOOKINGS
  # ================================
  resources :bookings, only: [ :index, :show, :edit, :update, :destroy ] do
    resource :review,  only: [ :new, :create ]
    resource :payment, only: [ :new ], controller: "payments" do
      get  :bank_transfer
      post :confirm_transfer
    end
  end

  # ================================
  # EVENTS (standalone)
  # ================================
  resources :events, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]

  # ================================
  # TATTOO STYLES
  # ================================
  resources :tattoo_styles, only: [ :index ]

  # ================================
  # FAVORITES (index global)
  # ================================
  resources :favorites, only: [ :index ]

  # ================================
  # CONVERSATIONS & MESSAGES
  # ================================
  resources :conversations, only: [ :index, :show, :create ] do
    resources :messages, only: [ :create ]
  end

  # ================================
  # ACTION CABLE
  # ================================
  mount ActionCable.server => "/cable"
end
