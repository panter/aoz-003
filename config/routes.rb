Rails.application.routes.draw do
  devise_for :users, :profiles

  resource :user, only: [:edit,:edit_email] do
    collection do
      patch 'update_password'
      patch 'update_email'
      get 'edit_email'
    end
  end

  resources :profiles, except: [:index, :destroy]
  root 'application#logged_in'
end
