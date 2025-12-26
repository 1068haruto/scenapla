Rails.application.routes.draw do
  root "static_pages#index"
  get "terms", to: "static_pages#terms"
  get "privacy", to: "static_pages#privacy"
  get "dashboard", to: "static_pages#dashboard"

  devise_for :users, controllers: {
    confirmations: "users/confirmations",
    passwords: "users/passwords",
    registrations: "users/registrations",
    sessions: "users/sessions",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  devise_scope :user do
    get "users/dob/edit", to: "users/registrations#edit_dob", as: "edit_dob"
    patch "users/dob", to: "users/registrations#update_dob", as: "update_dob"
  end

  resources :incomes, only: [ :index, :create, :edit, :update, :destroy ] do
    collection { post :update_sim }
  end
  resources :expenses, only: [ :index, :create, :edit, :update, :destroy ] do
    collection { post :update_sim }
  end
  resources :user_assets, only: [ :index, :create, :edit, :update, :destroy ] do
    collection { post :update_sim }
  end
  resources :life_events, only: [ :index, :create, :edit, :update, :destroy ] do
    collection { post :update_sim }
  end
  resources :users, only: [ :show ]
  resources :news, only: [ :index ]

  resources :scenarios, only: [ :index ] do
    collection do
      post :update_scenarios_lifespan
    end
  end

  resources :life_plans, only: [ :index ] do
    collection do
      post :generate_advice

      # POST, PATCH 両方許可
      match "save_memo", to: "life_plans#save_memo", via: [ :post, :patch ]
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
