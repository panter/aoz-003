Rails.application.routes.draw do
  devise_for :users

  concern :update_submitted_at do
    get :last_submitted_hours_and_feedbacks, on: :member
    get :update_submitted_at, on: :member
    put :update_submitted_at, on: :member
  end
  concern :assignment_feedbacks do
    resources :feedbacks
    resources :trial_feedbacks
  end
  concern :mark_doneable do
    put :mark_feedback_done, on: :member, to: 'list_responses#mark_feedback_done'
    put :mark_trial_feedback_done, on: :member, to: 'list_responses#mark_tryal_feedback_done'
    put :mark_hour_done, on: :member, to: 'list_responses#mark_hour_done'
  end

  resources :volunteer_applications, only: [:new, :create] do
    get :thanks, on: :collection
  end
  resources :client_notifications
  resources :clients do
    resources :journals, except: [:show]
    get :search, on: :collection
  end
  resources :departments
  resources :performance_reports
  resources :email_templates
  resources :users
  resources :profiles, except: [:destroy, :index]
  resources :group_offer_categories, except: [:destroy]
  resources :feedbacks, only: [:new, :create]
  resources :volunteers do
    get :seeking_clients, on: :collection
    get :need_review, on: :collection, to: 'trial_feedbacks#need_review'
    get :find_client, on: :member, to: 'assignments#find_client'
    resources :journals, except: [:show]
    resources :hours, concerns: :mark_doneable
    resources :billing_expenses, except: [:edit, :update]
    resources :certificates
<<<<<<< HEAD
    resources :group_offers, concerns: :assignment_feedbacks
    resources :assignments, concerns: :assignment_feedbacks
=======
    resources :group_offers do
      resources :hours, only: :show, concerns: :mark_doneable
      resources :feedbacks, concerns: :mark_doneable
      resources :trial_feedbacks, concerns: :mark_doneable
    end
    resources :assignments do
      resources :hours, only: :show, concerns: :mark_doneable
      resources :feedbacks, concerns: :mark_doneable
      resources :trial_feedbacks, concerns: :mark_doneable
    end
  end
  resources :group_assignments, only: [:update, :show] do
    get :last_submitted_hours_and_feedbacks, on: :member
  end
  resources :assignments do
    get :last_submitted_hours_and_feedbacks, on: :member
>>>>>>> hoam
  end
  resources :group_assignments, only: [:show], concerns: :update_submitted_at
  resources :assignments, concerns: :update_submitted_at
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
  get 'list_responses/feedbacks'
  get 'list_responses/hours'

  root 'application#home'
end
