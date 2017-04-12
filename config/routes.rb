Rails.application.routes.draw do
  resources :clients
  devise_for :users
  resources :users, except: :destroy
  resources :profiles, except: %i[destroy index]

  root 'application#logged_in'
end
