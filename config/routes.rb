Rails.application.routes.draw do
  devise_for :users
  resources :users, except: :destroy

  resources :profiles, except: [:destroy, :index]

  root 'users#show'
end
