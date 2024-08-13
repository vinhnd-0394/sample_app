FactoryBot.define do
  factory :user, class: User.name do
    name { "Vinh" }
    sequence(:email) { |n| "vinh_#{n}@gmail.com" }
    password { "123456" }
    avatar { "vinh.jpg" }
  end
end
