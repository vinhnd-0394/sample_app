class PostsController < ApplicationController
  before_action :user_logged_in, except: %i(index new show)
  before_action :find_post_by_id, except: %i(index new create)
  before_action :owner, only: %i(edit update destroy)

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

  def update
    if @post.update post_params
      flash[:success] = t "post.update.success.message"
      redirect_to @post
    else
      flash.now[:danger] = t "post.update.failed.message"
      render :edit, status: :unprocessable_entity
    end
  end

  def show; end

  def edit; end

  def destroy
    if @post.destroy
      flash[:success] = t "post.delete.success.message"
    else
      flash[:danger] = t "post.delete.failed.message"
    end
    redirect_to root_path
  end

  private

  def post_params
    params.require(:post).permit Post::PERMITTED_ATTRIBUTES
  end

  def find_post_by_id
    @post = Post.find_by id: params[:id]
    return if @post

    flash[:danger] = t "post.not_found"
    redirect_to root_path
  end

  def owner
    return if @post.is_owner? current_user

    flash[:danger] = t "post.not_owner"
    redirect_to root_path
  end
end
