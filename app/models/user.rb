class User < ApplicationRecord
  PERMITTED_ATTRIBUTES = %i(name email password avatar).freeze

  before_save :downcase_email!

  has_many :posts, dependent: :destroy
  has_many :active_relationships, class_name: Follow.name,
                                  foreign_key: :follower_id,
                                  dependent: :destroy

  has_many :passive_relationships, class_name: Follow.name,
                                   foreign_key: :followed_id,
                                   dependent: :destroy

  has_many :followers, through: :passive_relationships, source: :follower
  has_many :following, through: :active_relationships, source: :followed
  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :post

  has_secure_password

  validates :email, uniqueness: true,
                    presence: true,
                    format: {with: Settings.regex.email}
  validates :name, presence: true,
                    length: {maximum: Settings.digit.length_50}
  validates :password, presence: true,
                    length: {minimum: Settings.digit.length_6}

  delegate :count, to: :following, prefix: true

  delegate :count, to: :followers, prefix: true

  scope :top_users, lambda {|limit = Settings.limit.limit_10|
    left_joins(:posts)
      .where(posts: {status: :published})
      .group(:id)
      .order("COUNT(posts.id) DESC")
      .limit(limit)
  }

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost:
    end
  end

  def like post
    liked_posts << post
  end

  def follow other_user
    following << other_user unless self == other_user
  end

  def is_liked? post = nil
    return if post.blank?

    liked_posts.include? post
  end

  def is_following? user = nil
    return if user.blank?

    followers.include? user
  end

  def post_count
    posts.count
  end

  def unlike post
    liked_posts.delete post
  end

  def unfollow other_user
    following.delete other_user
  end

  private
  def downcase_email!
    email.downcase!
  end
end
