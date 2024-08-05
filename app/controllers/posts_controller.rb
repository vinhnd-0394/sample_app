class PostsController < ApplicationController
  def index
    @pagy, @posts = pagy Post.includes(:user), limit: Settings.post.limit
  end

  def show
    @post = Post.find_by id: params[:id]
    return if @post.present?

    flash[:danger] = t "post.not_found"
    redirect_to root_path
  end
end
