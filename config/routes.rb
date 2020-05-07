Rails.application.routes.draw do
  # Route Concerns
  #

  concern :submit_feedback do
    get :last_submitted_hours_and_feedbacks, on: :member
    put :submit_feedback, on: :member
    get :hours_and_feedbacks_submitted, on: :collection
  end

  concern :hours_resources do
    resources :hours
  end

  concern :search do
    get :search, on: :collection
  end

  concern :assignment_feedbacks do
    resources :hours
    resources :feedbacks do
      put :mark_as_done, on: :member
      put :take_responsibility, on: :member
    end
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

  concern :reactivate do
    get :reactivate, on: :member
  end

  # Resource and other Routes
  #

  devise_for :users
  resources :users do
    collection do
      match 'search' => 'users#search', via: :get, as: :search
    end
  end

  resources :assignments, except: [:destroy], concerns: [:submit_feedback, :termination_actions, :reactivate] do
    get :volunteer_search, on: :collection
    get :client_search, on: :collection
  end
  resources :client_notifications, :departments, :performance_reports, :email_templates, :users

  resources :clients, concerns: [:search, :reactivate] do
    resources :journals, except: [:show]
    patch :set_terminated, on: :member
    put :reserve, on: :member
  end

  resources :events do
    resources :event_volunteers, only: [:create, :destroy]
  end

  resources :group_assignments, only: [:show, :create, :edit, :update],
    concerns: [:submit_feedback, :termination_actions, :reactivate] do
    put :set_end_today, on: :member
  end

  resources :group_offer_categories, except: [:destroy]

  resources :group_offers, except: [:destroy], concerns: :search do
    put :change_active_state, on: :member
    get :initiate_termination, on: :member
    put :submit_initiate_termination, on: :member
    patch :end_all_assignments, on: :member
    get :search_volunteer, on: :member
    resources :journals, except: [:show]
  end

  resources :profiles, except: [:destroy, :index]

  resources :reminder_mailings, except: [:new]

  resources :trial_periods, only: %i[index update]

  resources :documents

  resources :semester_process_volunteers do
    get :review_semester, on: :member
    put :take_responsibility, on: :member
    put :mark_as_done, on: :member
    put :update_notes, on: :member
  end

  resources :review_semesters do
    get :review_semester, on: :member
    patch :submit_review, on: :member
  end

  resources :semester_processes, except: [:destroy, :index, :show] do
    get :overdue, on: :member
  end

  resources :volunteer_applications, only: [:new, :create] do
    get :thanks, on: :collection
  end

  resources :volunteers, except: [:destroy], concerns: [:search, :reactivate] do
    put :terminate, on: :member
    put :account, on: :member
    get :find_client, on: :member, to: 'assignments#find_client'
    get :seeking_clients, on: :collection
    patch :update_bank_details, on: :member

    resources :assignments, except: [:destroy], concerns: [:assignment_feedbacks, :hours_resources, :reactivate]
    resources :billing_expenses, only: [:index]
    resources :certificates
    resources :group_assignments, only: [:show, :edit, :update], concerns: [:hours_resources, :reactivate]
    resources :group_offers, except: [:destroy], concerns: :assignment_feedbacks
    resources :hours
    resources :journals, except: [:show]
  end

  resources :billing_expenses, except: [:edit, :update] do
    put :update_overwritten_amount, on: :member
    post :download, on: :collection
  end

  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  root 'application#home'
end
