Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  get "/home", to: "pages#home"
  resources :projects, only: %i[index new create destroy] do
    resources :components, only: %i[index new create show] do
      get :preview, on: :member
    end
  end

  resources :components, only: [:destroy]
  resources :chats, only: [:show] do
    resources :messages, only: [:create]
  end
end
