Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  authenticated :user do
    mount GoodJob::Engine => 'good_job'
  end

  resources :people do
    member do
      post :resync
    end
  end
  resources :users, only: [:index, :show] do 
    member do
      post :sync
    end
  end
  root to: "home#index"
end
