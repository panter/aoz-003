Rails.application.routes.draw do
  devise_for :users
  resources :users, except: :destroy

  root 'application#logged_in'
end
