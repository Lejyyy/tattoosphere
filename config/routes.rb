Rails.application.routes.draw do
  get "pages/home"
  get "tattoo_styles/index"
  get "shop_tatoueurs/create"
  get "shop_tatoueurs/destroy"
  get "socials/index"
  get "medias/index"
  get "availabilities/index"
  get "availabilities/new"
  get "events/index"
  get "events/show"
  get "events/new"
  get "events/edit"
  get "portfolio_items/index"
  get "portfolio_items/show"
  get "portfolio_items/new"
  get "portfolio_items/edit"
  get "portfolios/index"
  get "portfolios/show"
  get "portfolios/new"
  get "reviews/new"
  get "reviews/create"
  get "bookings/index"
  get "bookings/show"
  get "bookings/new"
  get "bookings/edit"
  get "tatoueurs/index"
  get "tatoueurs/show"
  get "tatoueurs/new"
  get "tatoueurs/edit"
  get "shops/index"
  get "shops/show"
  get "shops/new"
  get "shops/edit"
  devise_for :users

  root "pages#home"

  # ================================
  # SHOPS
  # ================================
  resources :shops do
    resources :bookings, only: [ :new, :create ]
    resources :events, only: [ :index, :show ]
    resources :medias, only: [ :index ]
    resources :socials, only: [ :index ]
    member do
      post :add_tatoueur    # associer un tatoueur au shop
      delete :remove_tatoueur # dissocier un tatoueur du shop
    end
  end

  # ================================
  # TATOUEURS
  # ================================
  resources :tatoueurs do
    resources :portfolios do
      resources :portfolio_items
    end
    resources :availabilities, only: [ :index, :create, :destroy ]
    resources :reviews, only: [ :index ]
    resources :events, only: [ :index, :show ]
    resources :medias, only: [ :index ]
    resources :socials, only: [ :index ]
  end

  # ================================
  # BOOKINGS
  # ================================
  resources :bookings, only: [ :index, :show, :edit, :update, :destroy ] do
    resource :review, only: [ :new, :create ]
  end

  # ================================
  # EVENTS
  # ================================
  resources :events, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]

  # ================================
  # TATTOO STYLES
  # ================================
  resources :tattoo_styles, only: [ :index ]
end
