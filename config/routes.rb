Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  resources :people
  resources :users, only: [:index, :show] do 
    member do
      post :sync
    end
  end
  root to: "home#index"
end
