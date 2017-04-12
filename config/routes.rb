Rails.application.routes.draw do
  resources :clients
  devise_for :users
  resources :users, except: :destroy

  resources :profiles, except: [:destroy, :index]

  root 'users#index'
end
