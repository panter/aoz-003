Rails.application.routes.draw do
  resources :clients
  devise_for :users
  resources :users

  root 'application#logged_in'
end
