class PostsController < ApplicationController
  def index
    @pagy, @posts = pagy Post.all.includes(:user), limit: Settings.post.limit
  end
end
