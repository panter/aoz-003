Rails.application.routes.draw do

  resources :assignments
  resources :volunteer_applications, only: [:new, :create] do
    get :thanks, on: :collection
  end

  # Authenticated routes start here
  devise_for :users

  resources :users
  resources :clients do
    get :need_accompanying, on: :collection
    get :find_volunteer, on: :member, to: 'assignments#find_volunteer'
  end
  resources :departments
  resources :volunteers
  resources :volunteer_emails
  resources :profiles, except: [:destroy, :index]

  root 'application#home'
end
