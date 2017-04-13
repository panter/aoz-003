Rails.application.routes.draw do
  devise_for :users

  resources :users, except: :destroy
  resources :clients
  resources :profiles, except: [:destroy, :index]

  root 'users#index'
end
