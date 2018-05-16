Rails.application.routes.draw do
  # Route Concerns
  #

  concern :update_submitted_at do
    get :last_submitted_hours_and_feedbacks, on: :member
    put :update_submitted_at, on: :member
    get :hours_and_feedbacks_submitted, on: :collection
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
    resources :hours
    resources :feedbacks, concerns: :mark_submitted_at
    resources :trial_feedbacks, concerns: :mark_submitted_at
  end

  concern :termination_actions do
    member do
      get :terminate
      put :update_terminated_at
      patch :verify_termination
    end

    get :terminated_index, on: :collection

    resources :reminder_mailings do
      get :new_termination, on: :collection
      get :send_termination, on: :member
    end
  end

  # Resource and other Routes
  #

  devise_for :users
  resources :users do
    collection do
      match 'search' => 'users#search', via: :get, as: :search
    end
  end

  resources :assignments, except: [:destroy], concerns: [:update_submitted_at, :termination_actions] do
    get :volunteer_search, on: :collection
    get :client_search, on: :collection
  end
  resources :client_notifications, :departments, :performance_reports, :email_templates, :users

  resources :clients, except: [:destroy], concerns: :search do
    resources :journals, except: [:show]
    patch :set_terminated, on: :member
  end

  resources :events do
    resources :event_volunteers, only: [:create, :destroy]
  end

  resources :feedbacks, only: [:new, :create]
  resources :group_assignments, only: [:show, :create, :edit, :update],
    concerns: [:update_submitted_at, :hours_resources, :termination_actions] do
    put :set_end_today, on: :member
  end

  resources :group_offer_categories, except: [:destroy]

  resources :group_offers, except: [:destroy], concerns: :search do
    put :change_active_state, on: :member
    get :initiate_termination, on: :member
    put :submit_initiate_termination, on: :member
    patch :end_all_assignments, on: :member
    get :search_volunteer, on: :member
  end

  get 'list_responses/feedbacks', to: 'list_responses#feedbacks'
  get 'list_responses/trial_feedbacks', to: 'list_responses#trial_feedbacks'

  resources :profiles, except: [:destroy, :index]

  resources :reminder_mailings, except: [:new] do
    get :new_trial_period, on: :collection
    get :new_half_year, on: :collection
    get :send_trial_period, on: :member
    get :send_half_year, on: :member
  end

  resources :volunteer_applications, only: [:new, :create] do
    get :thanks, on: :collection
  end

  resources :volunteers, except: [:destroy], concerns: :search do
    put :terminate, on: :member
    put :account, on: :member
    get :find_client, on: :member, to: 'assignments#find_client'
    get :seeking_clients, on: :collection

    resources :assignments, except: [:destroy], concerns: [:assignment_feedbacks, :hours_resources]
    resources :billing_expenses, only: [:index]
    resources :certificates
    resources :group_assignments, only: [:show, :edit, :update], concerns: :hours_resources
    resources :group_offers, except: [:destroy], concerns: :assignment_feedbacks
    resources :hours
    resources :journals, except: [:show]
  end

  resources :billing_expenses, except: [:edit, :update] do
    post :download, on: :collection
  end

  root 'application#home'
end
