Rails.application.routes.draw do
  devise_for :users, :profiles

  resources :profiles, except: [:index, :destroy]
  root 'application#logged_in'
end
