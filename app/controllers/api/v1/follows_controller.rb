class Api::V1::FollowsController < Api::V1::ApplicationController
  before_action :user_logged_in, only: %i(create destroy)
  before_action :find_user_by_id, only: %i(create destroy)

  def create
    unless current_user.follow @user
      return response_bad_request t("user.follow.failed")
    end

    response_ok t("user.follow.success")
  end

  def destroy
    unless current_user.unfollow @user
      return response_unprocessable_entity t("user.unfollow.failed")
    end

    response_ok t("user.unfollow.success")
  end

  private
  def find_user_by_id
    @user = User.find_by id: params[:id]
    return if @user

    response_not_found t("user.not_found")
  end
end
