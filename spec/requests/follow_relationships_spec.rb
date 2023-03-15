require "rails_helper"

RSpec.describe "/follow_relationships", type: :request do
  let(:valid_headers) do
    {}
  end

  describe "GET /show" do
    let!(:follow_relationship) { create(:follow_relationship) }

    it "renders a successful response" do
      get follow_relationship_url(follow_relationship), as: :json

      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let!(:follower) { create(:user) }
      let!(:followee) { create(:user) }

      let(:valid_attributes) do
        {
          follower_id: follower.id,
          followee_id: followee.id
        }
      end

      it "creates a new follow relationship" do
        expect {
          post follow_relationships_url,
            params: {follow_relationship: valid_attributes}, headers: valid_headers, as: :json
        }.to change(FollowRelationship, :count).by(1)
      end

      it "renders a JSON response with the new follow_relationship", aggregate_failures: true do
        post follow_relationships_url,
          params: {follow_relationship: valid_attributes}, headers: valid_headers, as: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      let!(:followee) { create(:user) }

      let(:non_existent_follower_id) { 0 }

      let(:invalid_attributes) do
        {
          follower_id: non_existent_follower_id,
          followee_id: followee.id
        }
      end

      before do
        expect(User.where(id: non_existent_follower_id)).to be_empty
      end

      it "does not create a new follow relationship" do
        expect {
          post follow_relationships_url,
            params: {follow_relationship: invalid_attributes}, as: :json
        }.to change(FollowRelationship, :count).by(0)
      end

      it "renders a JSON response with errors for the new follow_relationship", aggregate_failures: true do
        post follow_relationships_url,
          params: {follow_relationship: invalid_attributes}, headers: valid_headers, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    let!(:follow_relationship) { create(:follow_relationship) }

    it "destroys the requested follow relationship" do
      expect {
        delete follow_relationship_url(follow_relationship), headers: valid_headers, as: :json
      }.to change(FollowRelationship, :count).by(-1)
    end
  end
end
