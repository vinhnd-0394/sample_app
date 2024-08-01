class User < ApplicationRecord
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

  validates :name, presence: true
  validates :email, presence: true
end
