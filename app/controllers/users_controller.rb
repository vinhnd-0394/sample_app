class UsersController < ApplicationController
  def new
    if logged_in?
      redirect_to root_path
    else
      @user = User.new
    end
  end

  def create
    @user = User.new user_params
    if @user.save
      flash[:success] = t "register.success.message"
      redirect_to root_path
    else
      flash.now[:danger] = t "register.error"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "user.not_found"
    redirect_to root_path
  end

  private
  def user_params
    params.require(:user).permit User::PERMITTED_ATTRIBUTES
  end
end
