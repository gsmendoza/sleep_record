require "rails_helper"

RSpec.describe User, type: :model do
  describe "#friends" do
    let!(:user_a) { create(:user) }
    let!(:user_b) { create(:user) }

    before do
      expect(FollowRelationship.count).to eq(0)
    end

    context "when the user A and another user B are following each other" do
      let!(:follow_relationships) do
        [
          create(:follow_relationship, follower: user_a, followee: user_b),
          create(:follow_relationship, follower: user_b, followee: user_a)
        ]
      end

      it "includes user B" do
        expect(user_a.friends).to include(user_b)
      end
    end

    context "when neither user A or user B is following each other" do
      before do
        expect(FollowRelationship.count).to eq(0)
      end

      it "excludes user B" do
        expect(user_a.friends).not_to include(user_b)
      end
    end

    context "when only user A is following user B" do
      let!(:follow_relationship) do
        create(:follow_relationship, follower: user_a, followee: user_b)
      end

      it "excludes user B" do
        expect(user_a.friends).not_to include(user_b)
      end
    end

    context "when only user B is following user A" do
      let!(:follow_relationship) do
        create(:follow_relationship, follower: user_b, followee: user_a)
      end

      it "excludes user B" do
        expect(user_a.friends).not_to include(user_b)
      end
    end
  end
end
