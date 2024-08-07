class FollowsController < ApplicationController
  before_action :user_logged_in, only: %i(create destroy)
  before_action :find_user_by_id, only: %i(create destroy)

  def create
    if current_user.follow @user
      flash.now[:success] = t "user.follow.success"
    else
      flash.now[:danger] = t "user.follow.failed"
    end

    respond_to do |format|
      format.html{redirect_to @user}
      format.turbo_stream
    end
  end

  def destroy
    if current_user.unfollow @user
      flash.now[:success] = t "user.unfollow.success"
    else
      flash.now[:danger] = t "user.unfollow.failed"
    end

    respond_to do |format|
      format.html{redirect_to @user}
      format.turbo_stream
    end
  end

  private
  def find_user_by_id
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "user.not_found"
    redirect_to root_path
  end
end
