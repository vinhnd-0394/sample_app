FactoryBot.define do
  factory :post, class: Post.name do
    user
    content { Faker::Lorem }
    status { [:published, :unpublished].sample }
  end
end
