Rails.application.routes.draw do
  devise_for :users

  resources :users
  resources :clients
  resources :profiles, except: [:destroy, :index]

  root 'application#home'
end
