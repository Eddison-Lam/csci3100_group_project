Rails.application.routes.draw do
  devise_for :users
  get "up" => "rails/health#show", as: :rails_health_check
  namespace :admin do
    resources :resources, only: [ :index ]
  end

  # Home page
  get "pages/home"
  root "pages#home"
end
