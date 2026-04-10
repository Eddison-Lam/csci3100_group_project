Rails.application.routes.draw do
  devise_for :users
  get "up" => "rails/health#show", as: :rails_health_check
  namespace :admin do
    resources :resources, only: [ :index ]
  end

  # Student-facing routes
  resources :rooms, only: [ :index, :show ] do
    member do
      get :availability  # AJAX endpoint for slot data
    end
  end

  resources :equipment, only: [ :index, :show ] do
    member do
      get :availability
    end
  end

  resources :bookings, only: [ :new, :create, :show, :index, :destroy ] do
    member do
      get  :payment     # mock payment page
      post :pay         # process mock payment
    end
  end

  # Home page
  get "pages/home"
  root "pages#home"
end
