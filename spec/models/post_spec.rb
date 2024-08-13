require "rails_helper"

RSpec.describe Post, type: :model do

  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }

  let!(:post) { create(:post, user: user, status: :published, created_at: Time.current) }
  let!(:post1) { create(:post, user: user, status: :published, created_at: 1.day.ago) }
  let!(:post2) { create(:post, user: user, status: :published, created_at: 2.days.ago) }
  let!(:post3) { create(:post, user: user, status: :unpublished) }

  shared_examples :validates_presence_of do |attr|
    it { should validate_presence_of(attr)}
  end

  shared_examples :validates_length_of do |attr, max_length, min_length|
    it { should validate_length_of(attr).is_at_most(max_length) } if max_length

    it { should validate_length_of(attr).is_at_least(min_length) } if min_length
  end

  describe "Validation" do
    it "is valid with valid attributes" do
      expect(post).to be_valid
    end

    context "When validating content" do
      include_examples :validates_presence_of, :content
      include_examples :validates_length_of, :content, Settings.digit.length_1000, nil
    end
  end

  describe "Association" do
    it { should belong_to(:user) }
    it { should have_many(:likers).through(:likes).source(:user) }
  end


  describe "Method" do
    context "is_owner?" do
      it "Returns true if the user is the owner" do
        expect(post.is_owner?(user)).to be_truthy
      end

      it "Returns false if the user is not the owner" do
        expect(post.is_owner?(other_user)).to be_falsey
      end

      it "Returns false if the user is nil" do
        expect(post.is_owner?(nil)).to be_falsey
      end
    end
  end

  describe "Scope" do
    context ":newest" do
      it "Returns posts in descending order of creation date" do
        expect(Post.newest).to match_array([post, post1, post2, post3])
      end

      it "Returns an empty array if no posts are present" do
        Post.delete_all
        expect(Post.newest).to be_empty
      end
    end

    context ":published" do
      it "Returns post with status is published" do
        expect(Post.published).to match_array([post, post1, post2])
      end

      it "Returns an empty array if no posts are present" do
        Post.destroy_all
        expect(Post.published).to be_empty
      end
    end
  end
end
