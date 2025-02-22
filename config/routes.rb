Rails.application.routes.draw do
  # サブドメインからルートドメインへリダイレクトする
  constraints(host: /^www\./) do
    match '(*path)', to: redirect { |params, request|
      "https://scenapla.com#{request.fullpath}"
    }, via: :all
  end

  devise_for :users, controllers: {
    confirmations: "users/confirmations",
    passwords: "users/passwords",
    registrations: "users/registrations",
    sessions: "users/sessions",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  devise_scope :user do
    # SNSログインユーザーの生年月日登録
    get "users/date_of_birth/edit", to: "users/registrations#edit_date_of_birth", as: "edit_date_of_birth"
    patch "users/date_of_birth", to: "users/registrations#update_date_of_birth", as: "update_date_of_birth"
  end

  # user関連
  resources :users, only: [ :show ]

  # income関連
  resources :incomes, only: [ :index, :create, :destroy ] do
    collection do
      post :update_simulation_data
    end
  end

  # expense関連
  resources :expenses, only: [ :index ] do
    collection do
      post :create_or_update
      post :update_simulation_data
    end
  end

  # user_asset関連
  resources :user_assets, only: [ :index, :create, :destroy ] do
    collection do
      post :update_simulation_data
    end
  end

  # life_event関連
  resources :life_events, only: [ :index, :new, :create, :destroy ] do
    collection do
      post :update_simulation_data
    end
  end

  # scenario関連
  resources :scenarios, only: [ :index ] do
    collection do
      post :update_scenarios
    end
  end

  # memo関連
  resources :memos, only: [ :create, :update ]

  # openai_advice関連
  resource :openai_advice, only: [] do
    collection do
      post :generate_advice
    end
  end

  root to: "home#index"  # home関連（トップページ）
  get "dashboard/index"  # ダッシュボード

  # static_page関連（利用規約 & プライバシーポリシー）
  get "static_pages/terms"
  get "static_pages/privacy"

  # レターオープナー関連
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # -----------------------------------------------------------

  # ニュースページ
  resources :news, only: [ :index ]

  # ヘルスチェック
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA関連
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
