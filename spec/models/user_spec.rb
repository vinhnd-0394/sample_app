require "rails_helper"

RSpec.describe User, type: :model do
  let!(:user) { create(:user) }
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }
  let!(:user3) { create(:user) }
  let!(:user4) { create(:user) }

  before do
    create_list(:post, 5, user: user, status: :published)
    create_list(:post, 3, user: user1, status: :published)
    create(:post, user: user2, status: :published)
    create(:post, user: user4, status: :unpublished)
  end

  shared_examples :validates_presence_of do |attr|
    it { should validate_presence_of(attr)}
  end

  shared_examples :validates_length_of do |attr, max_length, min_length|
    it { should validate_length_of(attr).is_at_most(max_length) } if max_length

    it { should validate_length_of(attr).is_at_least(min_length) } if min_length
  end

  describe "Validation" do
    it "is valid with valid attributes" do
      expect(user).to be_valid
    end

    context "When validating name" do
      include_examples :validates_presence_of, :name

      include_examples :validates_length_of, :name, Settings.digit.length_50, nil
    end

    context "When validating email" do
      include_examples :validates_presence_of, :email

      it "does not allow invalid email addresses" do
        invalid_emails = ["invalid_email", "user@domain", "user@.com", "user@domain.", "@domain.com"]

        invalid_emails.each do |invalid_email|
          user.email = invalid_email
          expect(user).not_to be_valid, "#{invalid_email.inspect} should be invalid"
        end
      end
    end

    context "When validating password" do
      include_examples :validates_presence_of, :password
      include_examples :validates_length_of, :password, nil, Settings.digit.length_6
    end
  end

  describe "Association" do
    it { should have_many(:posts) }

    it { should have_many(:liked_posts).through(:likes).source(:post) }

    it { should have_many(:following).through(:active_relationships).source(:followed) }

    it { should have_many(:followers).through(:passive_relationships).source(:follower) }
  end

  describe "Method" do
    it "Downcase email before save" do
      user.email = "TEST@gmail.com"
      user.send(:downcase_email!)
      expect(user.email).to eq("test@gmail.com")
    end

    context "When follow user" do
      before do
        user1.follow user2
      end

      it "Other user is on user's following list" do
        expect(user1.following).to include user2
      end


      it "User is on other user's follower list" do
        expect(user2.followers).to include user1
      end

      it "Does not allow a user to follow themselves" do
        expect(user1.follow user1).to be_nil
      end
    end

    context "When unfollow user" do
      before do
        user1.follow user2
        user1.unfollow user2
      end

      it "User is not on other user's follower list" do
        expect(user2.followers).not_to include(user1)
      end

      it "Other user is not on user's following list" do
        expect(user2.followers).not_to include(user1)
      end
    end
  end

  describe "Scope" do
    context ":top_users" do
      it "Returns users with the most published posts" do
        expect(User.top_users).to match_array([user, user1, user2])
      end

      it "Limits the number of users returned by the scope" do
        limit = 2
        expect(User.top_users(limit)).to match_array([user, user1])
      end

      it "Returns users with status is published" do
        User.destroy_all
        expect(User.top_users).to be_empty
      end
    end
  end
end
