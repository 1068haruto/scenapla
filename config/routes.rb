Rails.application.routes.draw do
  if Rails.env.production?
    constraints(host: /^www\./) do
      match "(*path)", to: redirect { |params, request|
        "https://scenapla.com#{request.fullpath}"
      }, via: :all
    end
  end

  root "home#index"
  get "static_pages/terms"
  get "static_pages/privacy"

  devise_for :users, controllers: {
    confirmations: "users/confirmations",
    passwords: "users/passwords",
    registrations: "users/registrations",
    sessions: "users/sessions",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  devise_scope :user do
    get "users/date_of_birth/edit", to: "users/registrations#edit_date_of_birth", as: "edit_date_of_birth"
    patch "users/date_of_birth", to: "users/registrations#update_date_of_birth", as: "update_date_of_birth"
  end

  resources :dashboard,   only: [ :index ]
  resources :users,       only: [ :show ]
  resources :incomes,     only: [ :index, :create, :edit, :update, :destroy ]
  resources :expenses,    only: [ :index, :create, :edit, :update, :destroy ]
  resources :user_assets, only: [ :index, :create, :edit, :update, :destroy ]
  resources :life_events, only: [ :index, :create, :destroy ]
  resources :life_plans,  only: [ :index ]
  resources :memos,       only: [ :create, :update ]
  resources :news,        only: [ :index ]

  resource :simulation, only: [] do
    post :update_income_data
    post :update_expense_data
    post :update_user_asset_data
    post :update_life_event_data
  end

  resources :scenarios, only: [ :index ] do
    collection do
      post :update_scenarios
    end
  end

  resource :openai_advice, only: [] do
    collection do
      post :generate_advice
    end
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # ヘルスチェック
  get "/up", to: "rails/health#show", as: "rails_health_check"

  # PWA関連
  get "/service-worker", to: "rails/pwa#service_worker", as: "pwa_service_worker"
  get "/manifest", to: "rails/pwa#manifest", as: "pwa_manifest"
end
