Rails.application.routes.draw do
  resources :volunteers

  devise_for :users

  resources :departments
  resources :users
  resources :clients
  resources :profiles, except: [:destroy, :index]

  root 'application#home'
end
