Rails.application.routes.draw do
  # ================================
  # PAGES & SEARCH
  # ================================
  root "pages#home"
  get "/dashboard", to: "dashboard#show", as: :dashboard
  get "/map",       to: "pages#map",      as: :map
  get "/search",    to: "searches#index", as: :search
  get "/explorer",  to: "explore#index",  as: :explore
  get "conversations/search_recipients", to: "conversations#search_recipients", as: :search_recipients

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
    resources :portfolios, only: [ :new, :create ], controller: "shop_portfolios"
    member do
      post   :add_tatoueur
      delete :remove_tatoueur
      patch  :update_profile_photo
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
    resources :blocked_slots,  only: [ :create, :destroy ]
    resources :availabilities, only: [ :index, :create, :destroy ]
    resources :reviews,        only: [ :index ]
    resources :events,         only: [ :index, :show ]
    resources :medias,         only: [ :index ]
    resources :socials,        only: [ :index ]
    member do
      get    :verification
      post   :submit_verification
      get    :connect_paypal
      get    :paypal_callback
      patch  :update_photos
      delete :delete_photo
      get "disponibilites", to: "tatoueurs/availabilities#index"
    end
  end

  # ================================
  # BOOKINGS
  # ================================
  resources :bookings, only: [ :index, :show, :edit, :update, :destroy ] do
    member do
      get :pdf, to: "bookings#show", defaults: { format: :pdf }
    end
    resource :review,  only: [ :new, :create ]
    resource :payment, only: [ :new ], controller: "payments" do
      get  :bank_transfer
      post :confirm_transfer
      post "paypal/create_order",  to: "payments#create_paypal_order",  as: :paypal_create_order
      post "paypal/capture_order", to: "payments#capture_paypal_order", as: :paypal_capture_order
    end
  end

  # ================================
  # EVENTS
  # ================================
  resources :events, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
    member do
      post   :participate
      delete :withdraw
    end
  end

  # ================================
  # TATTOO STYLES
  # ================================
  resources :tattoo_styles, only: [ :index ]

  # ================================
  # FAVORITES
  # ================================
  resources :favorites, only: [ :index ]

  # ================================
  # CONVERSATIONS & MESSAGES
  # ================================
  resources :conversations, only: [ :index, :show, :create, :destroy ] do
    resources :messages, only: [ :create ]
    member do
      get   :bubble
      patch :mark_read
    end
  end

  # ================================
  # ACTION CABLE
  # ================================
  mount ActionCable.server => "/cable"

  # ================================
  # ADMIN
  # ================================
  namespace :admin do
    root "dashboard#index"

    resources :users, only: [ :index, :show, :edit, :update, :destroy ] do
      member do
        patch :ban
        patch :unban
      end
    end

    resources :tatoueurs, only: [ :index, :show, :update ] do
      member do
        patch :approve
        patch :reject
        patch :ban
        patch :unban
        patch :feature
        patch :unfeature
      end
    end

    resources :shops, only: [ :index, :show, :update ] do
      member do
        patch :ban
        patch :unban
        patch :feature
        patch :unfeature
      end
    end

    resources :events, only: [ :index, :show, :edit, :update, :destroy ] do
      member do
        patch :feature
        patch :unfeature
      end
    end

    resources :onboarding_funnels, only: [ :index ] do
    member do
    post :send_reminder
      end
    end

    resources :reports,       only: [ :index, :show, :update ]
    resources :tattoo_styles, only: [ :index, :create, :update, :destroy ]
    resources :admin_logs,    only: [ :index ]

    get :stats, to: "dashboard#stats"
  end

  # ================================
  # PANEL TATOUEUR
  # ================================
  namespace :tatoueur_panel do
    root "dashboard#index"
    get   "stats",          to: "dashboard#stats"
    get   "bookings",       to: "bookings#index"
    get   "bookings/:id",   to: "bookings#show",  as: :booking
    patch "bookings/:id",   to: "bookings#update"
    get   "messages",       to: "messages#index"
    get   "photos",         to: "photos#index"
    patch "photos",         to: "photos#update"
    get   "disponibilites", to: "availabilities#index"
    get   "paiements",      to: "payments#index"
    get   "portfolio",      to: "portfolio#index"
    get   "verification",   to: "verification#index"
    get   "evenements",     to: "events#index"
    get   "avis",           to: "reviews#index"
  end

  # ================================
  # PANEL SHOP
  # ================================
  namespace :shop_panel do
    root "dashboard#index"
    get   "stats",        to: "dashboard#stats"
    get   "bookings",     to: "bookings#index"
    get   "bookings/:id", to: "bookings#show",  as: :booking
    patch "bookings/:id", to: "bookings#update"
    get   "messages",     to: "messages#index"
    get   "photos",       to: "photos#index"
    patch "photos",       to: "photos#update"
    get   "equipe",       to: "team#index"
    get   "evenements",   to: "events#index"
    get   "portfolios",   to: "portfolios#index"
  end

  # ================================
  # NOTIFICATIONS
  # ================================
  resources :notifications, only: [ :index, :destroy ] do
    collection do
      patch :mark_all_as_read
    end
    member do
      patch :mark_as_read
    end
  end

  # ================================
  # STRIPE & ABONNEMENTS
  # ================================
  post "/stripe/webhooks", to: "stripe_webhooks#create"

  resource :subscription, only: [] do
    get    :index,    on: :collection
    post   :checkout, on: :collection
    get    :success,  on: :collection
    delete :cancel,   on: :collection
    get    :portal,   on: :collection
  end

# ================================
# ONBOARDING
# ================================

scope :onboarding do
  get  "tatoueur", to: "onboarding#tatoueur",       as: :onboarding_tatoueur
  post "tatoueur", to: "onboarding#submit_tatoueur", as: :onboarding_submit_tatoueur
  get  "shop",     to: "onboarding#shop",            as: :onboarding_shop
  post "shop",     to: "onboarding#submit_shop",     as: :onboarding_submit_shop
end
end
