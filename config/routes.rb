Rails.application.routes.draw do
  namespace :admin do
      resources :oauth_providers
      resources :users

      root to: "oauth_providers#index"
    end
  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks' }
  root to: "home#index"
  get :index, to: "home#index"

  # 加入好友時的自我介紹訊息
  get "follow", to: "home#index"

  resources :orders
end