class PostSerializer < BaseSerializer
  LIST_POST = %i(id content created_at).freeze
  DETAIL_POST = %i(id content).freeze

  attributes :id, :content, :status, :created_at, :owner_name, :owner_avatar

  belongs_to :user

  def owner_name
    object.user.name
  end

  def owner_avatar
    object.user.avatar
  end
end
