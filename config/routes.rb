Rails.application.routes.draw do
  resources :volunteers

  devise_for :users

  resources :departments
  resources :users
  resources :clients
  resources :departments
  resources :profiles, except: [:destroy, :index]
  resources :users

  root 'application#home'
end
