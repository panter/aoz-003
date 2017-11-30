Rails.application.routes.draw do
  resources :volunteer_applications, only: [:new, :create] do
    get :thanks, on: :collection
  end

  devise_for :users

  resources :client_notifications
  resources :clients do
    get :need_accompanying, on: :collection
    get :with_assignment, on: :collection
    get :find_volunteer, on: :member, to: 'assignments#find_volunteer'
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
    resources :hours
    resources :billing_expenses, except: [:edit, :update]
    resources :certificates
    resources :group_offers do
      resources :feedbacks
      resources :trial_feedbacks
    end
    resources :assignments do
      resources :feedbacks
      resources :trial_feedbacks
    end
  end
  resources :group_assignments, only: [:update, :show] do
    get :last_submitted_hours_and_feedbacks, on: :member
  end
  resources :assignments do
    get :last_submitted_hours_and_feedbacks, on: :member
  end
  resources :group_offers do
    get :archived, on: :collection
    put :change_active_state, on: :member
  end

  resources :reminder_mailings, except: [:new] do
    get :new_probation_period, on: :collection
    get :new_half_year, on: :collection
    get :initiate_mailing, on: :member
  end

  root 'application#home'
end
