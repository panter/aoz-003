class ApplicationController < ActionController::Base
  include Pundit
  include PdfHelpers

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
    stored_location_for(current_user) ||
      if current_user.volunteer?
        volunteer_path(current_user.volunteer)
      elsif policy(Department).manager_with_department?
        department_path(current_user.department.first)
      elsif !current_user.profile
        new_profile_path
      else
        root_path
      end
  end

  def after_sign_out_path_for(current_user)
    new_user_session_path
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
