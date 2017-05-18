Rails.application.routes.draw do
  resources :volunteer_applications, only: [:new, :create] do
    get :thanks, on: :collection
  end

  devise_for :users

  resources :volunteers
  resources :users
  resources :clients
  resources :departments
  resources :profiles, except: [:destroy, :index]
  resources :users

  root 'application#home'
end
