class Post < ApplicationRecord
  PERMITTED_ATTRIBUTES = %i(status content).freeze

  enum status: {published: 1, unpublished: 0}

  belongs_to :user

  has_many :likes, dependent: :destroy
  has_many :likers, through: :likes, source: :user

  validates :content, :status, presence: true
  validates :content, length: {maximum: Settings.digit.length_1000}

  delegate :name, to: :user, prefix: true

  scope :newest, ->{order(created_at: :desc)}
  scope :published, ->{where status: :published}
  scope :order_likes_count, lambda {|order = Settings.order.desc|
                              left_joins(:likes)
                                .group(:id)
                                .order("COUNT(likes.id) #{order.upcase}")
                            }

  def is_owner? current_user
    return false if current_user.blank?

    user == current_user
  end

  class << self
    def ransackable_attributes(*)
      %w(content status created_at)
    end

    def ransackable_associations(*)
      %w(user likers)
    end
  end
end
