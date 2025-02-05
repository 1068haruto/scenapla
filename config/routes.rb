Rails.application.routes.draw do
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

  # -----------------------------------------------------------
  resources :expenses, only: [ :index ] do
    collection do
      post :create_or_update
    end
    member do
      post :update_simulation_data
    end
  end
  resources :user_assets do
    collection do
      post :update_simulation_data
    end
  end
  resources :life_events do
    collection do
      post :update_simulation_data
    end
  end
  resources :memos, only: %i[create update]
  resources :scenarios do
    collection do
      post :update_scenarios
    end
  end

  # ニュースページ
  resources :news, only: [ :index ]

  # トップページ
  root to: "home#index"

  # ダッシュボード
  get "dashboard" => "dashboard#index", as: :dashboard

  # 利用規約 & プライバシーポリシー
  get "static_pages/terms"
  get "static_pages/privacy"

  # レターオープナー用
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # ヘルスチェック
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA関連
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
