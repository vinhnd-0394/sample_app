class Post < ApplicationRecord
  enum status: {public: 1, private: 0}

  belongs_to :user

  has_many :likes, dependent: :destroy
  has_many :likers, through: :likes, source: :user

  validates :content, :status, presence: true
  validates :content, length: {maximum: Settings.post.content_max_length}
end
