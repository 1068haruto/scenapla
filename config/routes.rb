Rails.application.routes.draw do
  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks',
  }
  resources :users, only: [:show, :edit, :update]
  resources :incomes do
    collection do
      post :update_simulation_data
    end
  end
  resources :expenses, only: [:index] do
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
      post :update_life_event_data
    end
  end
  resources :memos, only: %i[create update]
  resources :simulations do
    member do
      post :update_scenario
    end
  end
  resources :scenarios, only: [:index]

  # トップページ
  root to: 'home#index'

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
