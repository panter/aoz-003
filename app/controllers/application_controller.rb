class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :authenticate_user!
  after_action :verify_authorized, unless: :devise_controller?

  delegate :superadmin?, to: :current_user
  delegate :department_manager?, to: :current_user
  delegate :social_worker?, to: :current_user
  delegate :volunteer?, to: :current_user

  def after_sign_in_path_for(current_user)
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

  private

  def user_not_authorized
    flash[:alert] = t('not_authorized')
    redirect_to(root_path)
  end
end
