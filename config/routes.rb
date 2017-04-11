Rails.application.routes.draw do
  resources :clients
  devise_for :users
  resources :users, except: :destroy

  root 'application#logged_in'
end
