class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  before_action :authenticate_user!

  def after_sign_in_path_for(current_user)
    if current_user.profile.blank?
      new_profile_path
    else
      current_user
    end
  end

  def logged_in; end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit :account_update, keys: :password
  end
end
