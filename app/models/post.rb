class Post < ApplicationRecord
  enum status: {published: 1, unpublished: 0}

  belongs_to :user

  has_many :likes, dependent: :destroy
  has_many :likers, through: :likes, source: :user

  validates :content, :status, presence: true
  validates :content, length: {maximum: Settings.post.content_max_length}

  delegate :name, to: :user, prefix: true
end
