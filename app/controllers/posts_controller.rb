class PostsController < ApplicationController
  before_action :user_logged_in, only: %i(new create)

  def index
    @pagy, @posts = pagy Post.published
                             .newest
                             .includes(:user),
                         limit: Settings.post.limit
  end

  def create
    @post = current_user.posts.build post_params
    if @post.save
      flash[:success] = t "post.create.success.message"
      redirect_to root_path
    else
      flash.now[:danger] = t "post.create.failed.message"
      render :new, status: :unprocessable_entity
    end
  end

  def new
    @post = Post.new
  end

  def show
    @post = Post.find_by id: params[:id]
    return if @post.present?

    flash[:danger] = t "post.not_found"
    redirect_to root_path
  end

  private
  def post_params
    params.require(:post).permit Post::PERMITTED_ATTRIBUTES
  end
end
