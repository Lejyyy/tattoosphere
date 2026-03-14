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
      get  :connect_paypal
      get  :paypal_callback
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
      post "paypal/create_order",  to: "payments#create_paypal_order",  as: :paypal_create_order
      post "paypal/capture_order", to: "payments#capture_paypal_order", as: :paypal_capture_order
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
# Dans config/routes.rb, remplace le bloc conversations :
resources :conversations, only: [ :index, :show, :create ] do
  resources :messages, only: [ :create ]
  member do
    patch :mark_read
  end
end

  # ================================
  # ACTION CABLE
  # ================================
  mount ActionCable.server => "/cable"

  namespace :admin do
  root "dashboard#index"
  resources :users,     only: [ :index, :show, :edit, :update, :destroy ]
  resources :tatoueurs, only: [ :index, :show, :update ]
  resources :shops,     only: [ :index, :show, :update ]
  end
end
