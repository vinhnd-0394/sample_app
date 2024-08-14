class Api::V1::PostsController < Api::V1::ApplicationController
  before_action :user_logged_in, only: %i(create update)
  before_action :find_post_by_id, only: :update
  before_action :owner, only: :update

  def index
    @q = Post.ransack(params[:q])
    @q.content_cont = params[:content]
    options = pagination_options

    @query_results = @q.result(distinct: true)
                       .published
                       .newest
                       .includes(:user)
    @pagy, @posts = pagy @query_results,
                         limit: options[:limit],
                         page: options[:page]
    response_ok(t("post.get.success"),
                {
                  posts: ActiveModel::Serializer::CollectionSerializer.new(
                    @posts, serializer: PostSerializer
                  ),
                  metadata: pagy_metadata(@pagy)
                })
  end

  def create
    @post = current_user.posts.build post_params
    unless @post.save
      return response_bad_request t("post.create.failed.message")
    end

    response_created(t("post.create.success.message"),
                     post: PostSerializer.new(@post))
  end

  def update
    unless @post.update post_params
      return response_bad_request t("post.update.failed.message")
    end

    response_ok(t("post.update.success.message"),
                post: PostSerializer.new(@post))
  end

  private

  def post_params
    params.require(:post).permit Post::PERMITTED_ATTRIBUTES
  end

  def find_post_by_id
    @post = Post.find_by id: params[:id]
    return if @post

    response_not_found t("post.update.success.message")
  end

  def owner
    return if @post.is_owner? current_user

    response_forbidden t("post.not_owner")
  end
end
