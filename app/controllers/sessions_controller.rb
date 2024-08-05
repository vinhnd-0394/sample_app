class SessionsController < ApplicationController
  def new
    return unless logged_in?

    redirect_to root_path
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    check_user_login user
  end

  def destroy
    log_out
    flash[:success] = t "logout.success.message"
    redirect_to root_url, status: :see_other
  end

  private
  def check_user_login user
    if user&.authenticate(params[:session][:password])
      reset_session
      log_in user
      flash[:success] = t "login.success.message"
      redirect_to root_path
    else
      flash.now[:danger] = t "login.failed.message"
      render :new, status: :unprocessable_entity
    end
  end
end
