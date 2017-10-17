Rails.application.routes.draw do
  resources :volunteer_applications, only: [:new, :create] do
    get :thanks, on: :collection
  end

  devise_for :users

  resources :clients do
    get :need_accompanying, on: :collection
    get :find_volunteer, on: :member, to: 'assignments#find_volunteer'
    resources :journals
  end
  resources :departments
  resources :performance_reports
  resources :volunteer_emails
  resources :users
  resources :profiles, except: [:destroy, :index]
  resources :reminders, only: [:index, :update, :destroy]
  resources :group_offer_categories, except: [:destroy]

  resources :feedbacks, only: [:new, :create]
  resources :volunteers do
    get :seeking_clients, on: :collection
    get :find_client, on: :member, to: 'assignments#find_client'
    resources :journals
    resources :hours
    resources :billing_expenses, except: [:edit, :update]
    resources :certificates
    resources :feedbacks
  end
  resources :assignments do
    resources :feedbacks
  end
  resources :group_offers do
    get :archived, on: :collection
    put :change_active_state, on: :member
    resources :feedbacks
  end

  root 'application#home'
end
