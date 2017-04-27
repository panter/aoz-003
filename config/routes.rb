Rails.application.routes.draw do
  resources :departements
  devise_for :users

  resources :users, except: :destroy
  resources :clients
  resources :profiles, except: [:destroy, :index]

  root 'application#home'
end
