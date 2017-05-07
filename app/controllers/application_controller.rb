class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  before_action :authenticate_user!

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def after_sign_in_path_for(current_user)
    if current_user.profile.blank?
      new_profile_path
    else
      root_path
    end
  end

  def home; end

  private

  def user_not_authorized
    flash[:alert] = t('user_not_authorized')
    redirect_to(root_path)
  end
end
