# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

User.create!({
  name: "Vinh đep trai",
  email: "vinh@gmail.com",
  password: "123456",
})

50.times do
  User.create!({
    name: Faker::Name.name,
    email: Faker::Internet.email(domain: "gmail.com"),
    password: "123456",
  })
end

users = User.pluck :id

200.times do
  Post.create!({
    content: Faker::Markdown.sandwich(sentences: 6, repeat: 3),
    user_id: users.sample,
    status: 1,
  })
end

users = User.all
user = users.first
following = users[2..10]
followers = users[3..10]
following.each { |followed| user.follow followed }
followers.each { |follower| follower.follow user }
