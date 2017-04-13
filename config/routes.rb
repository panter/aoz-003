Rails.application.routes.draw do
  resources :clients
  devise_for :users

  root 'application#logged_in'
end
