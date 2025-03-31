Rails.application.routes.draw do
  if Rails.env.production?
    constraints(host: /^www\./) do
      match "(*path)", to: redirect { |params, request|
        "https://scenapla.com#{request.fullpath}"
      }, via: :all
    end
  end

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

  resources :users, only: [ :show ]

  resources :incomes, only: [ :index, :create, :destroy ] do
    collection do
      post :update_simulation_data
    end
  end

  resources :expenses, only: [ :index ] do
    collection do
      post :create_or_update
      post :update_simulation_data
    end
  end

  resources :user_assets, only: [ :index, :create, :destroy ] do
    collection do
      post :update_simulation_data
    end
  end

  resources :life_events, only: [ :index, :new, :create, :destroy ] do
    collection do
      post :update_simulation_data
    end
  end

  resources :scenarios, only: [ :index ] do
    collection do
      post :update_scenarios
    end
  end

  resources :memos, only: [ :create, :update ]

  resource :openai_advice, only: [] do
    collection do
      post :generate_advice
    end
  end

  resources :news, only: [ :index ]

  root "home#index"           # トップ
  get "static_pages/terms"    # 利用規約
  get "static_pages/privacy"  # プライバシーポリシー
  get "dashboard/index"       # ダッシュボード

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # ヘルスチェック
  get "/up", to: "rails/health#show", as: "rails_health_check"

  # PWA関連
  get "/service-worker", to: "rails/pwa#service_worker", as: "pwa_service_worker"
  get "/manifest", to: "rails/pwa#manifest", as: "pwa_manifest"
end
