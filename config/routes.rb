Rails.application.routes.draw do
  resources :volunteer_applications, only: [:new, :create] do
    get :thanks, on: :collection
  end

  # Authenticated routes start here (Watch out!)
  devise_for :users

  resources :clients do
    get :need_accompanying, on: :collection
    get :find_volunteer, on: :member, to: 'assignments#find_volunteer'
    resources :journals
  end
  resources :departments
  resources :performance_reports
  resources :profiles, except: [:destroy, :index]
  resources :users
  resources :volunteers do
    get :seeking_clients, on: :collection
    get :find_client, on: :member, to: 'assignments#find_client'
    resources :journals
    resources :hours
    resources :billing_expenses, except: [:edit, :update]
    resources :certificates
  end
  resources :volunteer_emails
  resources :profiles, except: [:destroy, :index]
  resources :assignments do
    resources :feedbacks
  end
  resources :reminders, only: [:index, :update, :destroy]
  resources :group_offers do
    get :archived, on: :collection
    put :change_active_state, on: :member
  end
  resources :group_offer_categories, except: [:destroy]

  root 'application#home'
end
