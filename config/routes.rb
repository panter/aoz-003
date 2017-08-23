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
    resources :journals
  end
  resources :departments
  resources :volunteers do
    get :seeking_clients, on: :collection
    get :find_client, on: :member, to: 'assignments#find_client'
    resources :journals
    resources :hours
  end
  resources :volunteer_emails
  resources :profiles, except: [:destroy, :index]
  resources :assignment_journals

  root 'application#home'
end
