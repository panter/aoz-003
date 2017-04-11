Rails.application.routes.draw do
  resources :clients
  devise_for :users
  resources :users, except: :destroy

  #as :user do
  #  get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
  #  put 'users' => 'devise/registrations#update', :as => 'user_registration'
  #end

  root 'application#logged_in'
end
