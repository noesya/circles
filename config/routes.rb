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
      patch :hide
    end
    resources :interactions, only: [ :new, :create ]
  end
  resources :interactions, only: [ :edit, :update, :destroy ]
  resources :users, only: [:index, :show] do 
    member do
      post :sync
    end
    collection do
      post 'add/:person_id' => 'users#add_to_my_circle', as: :add_to_my_circle
      post 'remove/:person_id' => 'users#remove_from_my_circle', as: :remove_from_my_circle
    end
  end
  root to: "home#index"
end
