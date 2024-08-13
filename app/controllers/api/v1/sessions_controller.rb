class Api::V1::SessionsController < Api::V1::ApplicationController
  before_action :user_logged_in, only: :destroy

  def create
    user_login = User.find_by(email: params[:email]&.downcase)
    check_user_login user_login, params[:password]
  end

  def destroy
    log_out
    response_ok t("logout.success.message")
  end

  private
  def check_user_login user, password
    if user&.authenticate password
      reset_session
      log_in user
      response_created(t("login.success.message"),
                       UserSerializer.new(user, type: "DETAIL_USER"))
    else
      response_unauthorized t("login.failed.message")
    end
  end
end
