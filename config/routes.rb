Rails.application.routes.draw do
  devise_for :users
  resources :users, except: :destroy

  resources :profiles, except: %i[destroy index]

  root 'application#logged_in'
end
