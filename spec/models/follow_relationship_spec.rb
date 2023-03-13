require "rails_helper"

RSpec.describe FollowRelationship, type: :model do
  describe "#valid?" do
    subject(:is_valid) { follow_relationship.valid? }

    let!(:follower) { create(:follower) }
    let!(:followee) { create(:followee) }

    let(:follow_relationship) do
      build(:follow_relationship, follower: follower, followee: followee)
    end

    describe "concerning uniqueness" do
      context "when the follow relationship does not exist" do
        before do
          expect(described_class.all).to be_empty
        end

        it { is_expected.to be_truthy }
      end

      context "when the follow relationship exists" do
        let!(:existing_follow_relationship) do
          create(:follow_relationship, follower: follower, followee: followee)
        end

        it "is expected to be falsey", :aggregate_failures do
          expect(is_valid).to be_falsey
          expect(follow_relationship.errors[:base]).to include("has already been taken")
        end
      end
    end

    describe "concerning self-following" do
      context "when the follower follows himself" do
        let(:followee) { follower }

        it "is expected to be falsey", :aggregate_failures do
          expect(is_valid).to be_falsey
          expect(follow_relationship.errors[:follower_id]).to include("is following himself")
        end
      end
    end
  end
end
