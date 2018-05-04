class ApplicationController < ActionController::Base
  include Pundit

  before_action :store_user_location!, if: :storable_location?

  protect_from_forgery with: :exception
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :authenticate_user!
  after_action :verify_authorized, unless: :devise_controller?

  before_action :ensure_profile_presence!

  delegate :superadmin?, to: :current_user
  delegate :department_manager?, to: :current_user
  delegate :social_worker?, to: :current_user
  delegate :volunteer?, to: :current_user

  def after_sign_in_path_for(current_user)
    location = stored_location_for(current_user)
    if location && location[/\/volunteers\/[0-9]+\/(group_)?assignments\/[0-9]+\//].present?
      return location
    end
    return volunteer_path(current_user.volunteer.id) if volunteer?
    return new_profile_path if current_user.profile.blank?
    if policy(Department).manager_with_department?
      return department_path(current_user.department.first.id)
    end
    root_path
  end

  def home
    authorize :application, :home?
  end

  def t_model
    controller_name.singularize.classify.constantize.model_name.human
  end

  def make_notice
    {
      notice: t("crud.c_action.#{action_name}", model: t_model)
    }
  end

  def set_default_filter(filters)
    params[:q] ||= filters
  end

  def default_redirect
    params[:redirect_to].presence
  end
  helper_method :default_redirect

  private

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  def user_not_authorized
    flash[:alert] = t('not_authorized')
    redirect_to(root_path)
  end

  def ensure_profile_presence!
    return unless current_user&.missing_profile?

    flash[:alert] = 'Bitte füllen Sie Ihr Profil aus um die Applikation zu verwenden.'
    redirect_to new_profile_path
  end
end
