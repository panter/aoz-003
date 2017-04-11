class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate_user!

  def after_sign_in_path_for(current_user)
    return new_profile_path if current_user.profile.blank?
    root_path
  end

  def logged_in; end
end
