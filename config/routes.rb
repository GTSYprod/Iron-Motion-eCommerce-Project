Rails.application.routes.draw do
  # Admin routes
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # User authentication (Requirement 3.1.4)
  devise_for :users

  # Public routes
  root 'products#index'

  resources :products, only: [:index, :show] do
    collection do
      get :search
    end
  end

  resources :categories, only: [:show]

  resource :shopping_cart, only: [:show] do
    post :add_item
    patch :update_item
    delete :remove_item
    delete :clear
  end

  namespace :checkout do
    get '/', to: 'checkout#new', as: ''
    post '/', to: 'checkout#create'
  end

  resources :orders, only: [:index, :show]
  resources :addresses

  # Static pages
  get 'about', to: 'pages#about'
  get 'contact', to: 'pages#contact'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
