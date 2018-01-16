Rails.application.routes.draw do
  devise_for :users

  resources :users do
    collection do
      match 'search' => 'users#search', via: :get, as: :search
    end
  end

  concern :update_submitted_at do
    get :last_submitted_hours_and_feedbacks, on: :member
    get :update_submitted_at, on: :member
    put :update_submitted_at, on: :member
  end

  concern :mark_submitted_at do
    put :mark_as_done, on: :member
  end

  concern :hours_resources do
    resources :hours
  end

  concern :search do
    get :search, on: :collection
  end

  concern :assignment_feedbacks do
    resources :hours, concerns: :mark_submitted_at
    resources :feedbacks, concerns: :mark_submitted_at
    resources :trial_feedbacks, concerns: :mark_submitted_at
  end

  resources :client_notifications, :departments, :performance_reports, :email_templates, :users
  resources :profiles, except: [:destroy, :index]
  resources :group_offer_categories, except: [:destroy]
  resources :feedbacks, only: [:new, :create]
  resources :group_assignments, only: [:show], concerns: [:update_submitted_at, :hours_resources]

  resources :assignments, concerns: [:update_submitted_at, :search] do
    member do
      get :terminate
      put :update_terminated_at
      patch :verify_termination
    end

    get :terminated_index, on: :collection

    resources :reminder_mailings do
      get :new_termination, on: :collection
    end
  end

  resources :volunteer_applications, only: [:new, :create] do
    get :thanks, on: :collection
  end

  resources :clients, concerns: :search do
    resources :journals, except: [:show]
  end

  resources :volunteers, concerns: :search do
    get :find_client, on: :member, to: 'assignments#find_client'
    get :seeking_clients, on: :collection
    resources :billing_expenses, except: [:edit, :update]
    resources :certificates
    resources :group_assignments, concerns: :hours_resources
    resources :group_offers, concerns: :assignment_feedbacks
    resources :hours
    resources :journals, except: [:show]
    resources :assignments, concerns: [:assignment_feedbacks, :hours_resources]
  end
  resources :group_assignments, only: [:show], concerns: [:update_submitted_at, :hours_resources]
  resources :group_offers, concerns: :search do
    put :change_active_state, on: :member
  end

  resources :reminder_mailings, except: [:new] do
    get :new_trial_period, on: :collection
    get :new_half_year, on: :collection
    get :send_trial_period, on: :member
    get :send_half_year, on: :member
  end

  get 'list_responses/hours', to: 'list_responses#hours'
  get 'list_responses/feedbacks', to: 'list_responses#feedbacks'
  get 'list_responses/trial_feedbacks', to: 'list_responses#trial_feedbacks'

  root 'application#home'
end
