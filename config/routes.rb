Rails.application.routes.draw do
  devise_for :users, :profiles
  resources :users, except: %i[destroy show] do
    collection do
      get 'edit_password'
      get 'edit_email'
      patch 'update_password'
      patch 'update_email'
    end
  end

  resources :profiles, except: %i[destroy index]

  root 'application#logged_in'
end
