class UserSerializer < BaseSerializer
  LIST_USER = %i(id name email).freeze
  DETAIL_USER = %i(id name email created_at).freeze

  attributes :id, :name, :email

  has_many :posts
end
