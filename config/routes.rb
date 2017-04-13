Rails.application.routes.draw do
  devise_for :users
  resources :clients

  root 'application#logged_in'
end
