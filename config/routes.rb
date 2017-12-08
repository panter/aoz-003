Rails.application.routes.draw do
  devise_for :users

  concern :update_submitted_at do
    get :last_submitted_hours_and_feedbacks, on: :member
    get :update_submitted_at, on: :member
    put :update_submitted_at, on: :member
  end

  concern :mark_submitted_at do
    put :mark_as_done, on: :member
  end

  concern :assignment_feedbacks do
    resources :feedbacks, concerns: :mark_submitted_at
    resources :trial_feedbacks, concerns: :mark_submitted_at
  end

  resources :client_notifications, :departments, :performance_reports, :email_templates, :users

  resources :profiles, except: [:destroy, :index]
  resources :group_offer_categories, except: [:destroy]
  resources :feedbacks, only: [:new, :create]
  resources :group_assignments, only: [:show], concerns: :update_submitted_at
  resources :assignments, concerns: :update_submitted_at

  resources :volunteer_applications, only: [:new, :create] do
    get :thanks, on: :collection
  end

  resources :clients do
    resources :journals, except: [:show]
  end

  resources :volunteers do
    get :find_client, on: :member, to: 'assignments#find_client'
    get :need_review, on: :collection, to: 'trial_feedbacks#need_review'
    get :seeking_clients, on: :collection
    resources :assignments, concerns: :assignment_feedbacks
    resources :billing_expenses, except: [:edit, :update]
    resources :certificates
    resources :group_offers, concerns: :assignment_feedbacks
    resources :hours, concerns: :mark_submitted_at
    resources :journals, except: [:show]
  end

  resources :group_offers do
    get :archived, on: :collection
    put :change_active_state, on: :member
  end

  resources :reminder_mailings, except: [:new] do
    get :new_probation_period, on: :collection
    get :new_half_year, on: :collection
    get :send_probation, on: :member
    get :send_half_year, on: :member
  end

  get 'list_responses/hours', to: 'list_responses#hours'
  get 'list_responses/feedbacks', to: 'list_responses#feedbacks'
  get 'list_responses/trial_feedbacks', to: 'list_responses#trial_feedbacks'

  root 'application#home'
end
