Rails.application.routes.draw do
  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    sessions: 'users/sessions',
  }
  resources :users, only: [:show, :edit, :update]
  resources :incomes, only: [:index, :create]
  resources :expenses, only: [:index, :create]
  resources :user_assets, only: [:index, :create, :destroy]
  resources :scenarios, only: [:index]

  # トップページ
  root to: 'home#index'

  # ダッシュボード
  get "dashboard" => "dashboard#index", as: :dashboard

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
