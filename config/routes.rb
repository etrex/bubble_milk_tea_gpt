Rails.application.routes.draw do
  # 後台
  namespace :admin do
    resources :oauth_providers
    resources :users

    root to: "oauth_providers#index"
  end

  # 登入
  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks' }

  # 首頁
  root to: "home#index"
  get :index, to: "home#index"

  # 加入好友時的自我介紹訊息
  get "follow", to: "home#index"

  # 訂單
  resources :orders, only: [:index, :show, :destroy]
  resources :items, only: [:index, :new, :create, :destroy]

  # 結帳
  get "前往結帳", to: "items#finish"

  # 重置對話
  get "reset", to: "home#reset"
end
