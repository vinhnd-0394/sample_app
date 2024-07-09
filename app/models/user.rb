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
  has_many :followeds, through: :active_relationships, source: :followed
  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :post

  has_secure_password

  validates :name, presence: true
  validates :email, presence: true,
    format: {with: Settings.user.valid_email_regex}

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

  private
  def downcase_email!
    email.downcase!
  end
end
