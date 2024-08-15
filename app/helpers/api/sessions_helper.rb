module Api::SessionsHelper
  def log_in user
    session[:user_id] = user.id
  end

  def current_user
    return unless session[:user_id]

    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def log_out
    reset_session
    @current_user = nil
  end

  def user_logged_in
    return if logged_in?

    response_unauthorized t("login.not_login.message")
  end
end
