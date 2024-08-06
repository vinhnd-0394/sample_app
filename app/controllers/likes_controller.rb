class LikesController < ApplicationController
  before_action :user_logged_in, only: %i(create destroy)
  before_action :find_post_by_id, only: %i(create destroy)

  def create
    if current_user.like @post
      flash.now[:success] = t "user.like.success"
    else
      flash.now[:danger] = t "user.like.failed"
    end

    respond_to do |format|
      format.html{redirect_to @post}
      format.turbo_stream
    end
  end

  def destroy
    if current_user.unlike @post
      flash.now[:success] = t "user.unlike.success"
    else
      flash.now[:danger] = t "user.unlike.failed"
    end

    respond_to do |format|
      format.html{redirect_to @post}
      format.turbo_stream
    end
  end

  private
  def find_post_by_id
    @post = Post.find_by id: params[:id]
    return if @post

    flash[:danger] = t "post.not_found"
    redirect_to root_path
  end
end
