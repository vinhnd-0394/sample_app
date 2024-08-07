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

  validates :name, presence: true
  validates :email, presence: true,
    format: {with: Settings.user.valid_email_regex}

  delegate :count, to: :following, prefix: true

  delegate :count, to: :followers, prefix: true

  scope :top_users, lambda {|limit = Settings.user.top_user_limit|
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

  def follow other_user
    following << other_user unless self == other_user
  end

  def is_following? user = nil
    return if user.nil?

    followers.include? user
  end

  def post_count
    posts.count
  end

  def unfollow other_user
    following.delete other_user
  end

  private
  def downcase_email!
    email.downcase!
  end
end
