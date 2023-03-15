require "rails_helper"

RSpec.describe "/sleep_records", type: :request do
  let(:valid_headers) do
    {}
  end

  describe "GET /index" do
    let!(:sleep_records) do
      create_list(:sleep_record, 3, :completed)
    end

    it "renders a successful response" do
      get sleep_records_url, headers: valid_headers, as: :json
      expect(response).to be_successful
    end

    context "when pagination params are specified" do
      let(:per) { 2 }

      it "paginates the results" do
        get sleep_records_url(page: 1, per: per), headers: valid_headers, as: :json

        expect(ActiveSupport::JSON.decode(response.body).size).to eq(per)
      end
    end
  end

  describe "GET /friend" do
    def get_sleep_records_of_friends
      get friend_sleep_records_url(user_id: user.id), headers: valid_headers, as: :json

      ActiveSupport::JSON.decode(response.body)
    end

    let!(:user) { create(:user) }

    it "renders a successful response" do
      get_sleep_records_of_friends

      expect(response).to be_successful
    end

    context "when the user doesn't have friends" do
      before do
        expect(FollowRelationship.count).to eq(0)
      end

      it "returns an empty set" do
        sleep_record_hashes = get_sleep_records_of_friends

        expect(sleep_record_hashes.size).to eq(0)
      end
    end

    context "when the user's friends do not have sleep records" do
      let!(:friend) { create(:user, :friend, friend: user) }

      before do
        expect(SleepRecord.count).to eq(0)
      end

      it "returns an empty set" do
        sleep_record_hashes = get_sleep_records_of_friends

        expect(sleep_record_hashes.size).to eq(0)
      end
    end

    context "when the user has a friend with an ongoing sleep record" do
      let!(:friend) { create(:user, :friend, friend: user) }
      let!(:sleep_record) { create(:sleep_record, :ongoing, user: friend) }

      it "returns an empty set" do
        sleep_record_hashes = get_sleep_records_of_friends

        expect(sleep_record_hashes.size).to eq(0)
      end
    end

    context "when the user has a friend with a completed sleep record" do
      let!(:friend) { create(:user, :friend, friend: user) }
      let!(:sleep_record) { create(:sleep_record, :completed, user: friend) }

      it "includes the sleep record of the friend", :aggregate_failures do
        sleep_record_hashes = get_sleep_records_of_friends

        expect(sleep_record_hashes.size).to eq(1)
        expect(sleep_record_hashes[0]["id"]).to eq(sleep_record.id)
      end
    end

    context "when the user has a friend with multiple sleep records" do
      let!(:friend) { create(:user, :friend, friend: user) }

      let!(:sleep_records) do
        [
          create(:sleep_record, :completed, :with_duration, user: friend, specified_duration: 9.hours),
          create(:sleep_record, :completed, :with_duration, user: friend, specified_duration: 8.hours)
        ]
      end

      it "includes the completed sleep records of the user's friend, ordered by duration", :aggregate_failures do
        sleep_record_hashes = get_sleep_records_of_friends

        expect(sleep_record_hashes.size).to eq(2)
        expect(sleep_record_hashes[0]["id"]).to eq(sleep_records[1].id)
        expect(sleep_record_hashes[0]["duration"]).to eq(8.hours)
      end
    end

    context "when the user has friends with sleep records" do
      let!(:friends) do
        [
          create(:user, :friend, friend: user),
          create(:user, :friend, friend: user)
        ]
      end

      let!(:sleep_records) do
        [
          create(:sleep_record, :completed, :with_duration, user: friends[1], specified_duration: 9.hours),
          create(:sleep_record, :completed, :with_duration, user: friends[0], specified_duration: 8.hours)
        ]
      end

      it "includes the completed sleep records of the user's friends, ordered by duration", :aggregate_failures do
        sleep_record_hashes = get_sleep_records_of_friends

        expect(sleep_record_hashes.size).to eq(2)
        expect(sleep_record_hashes[0]["id"]).to eq(sleep_records[1].id)
        expect(sleep_record_hashes[0]["duration"]).to eq(8.hours)
      end
    end
  end

  describe "GET /show" do
    let!(:sleep_record) { create(:sleep_record) }

    it "renders a successful response" do
      get sleep_record_url(sleep_record), as: :json

      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let!(:user) { create(:user) }

      let(:valid_attributes) do
        {
          user_id: user.id
        }
      end

      it "creates a new SleepRecord" do
        expect {
          post sleep_records_url,
            params: {sleep_record: valid_attributes}, headers: valid_headers, as: :json
        }.to change(SleepRecord, :count).by(1)
      end

      it "renders a JSON response with the new sleep_record", aggregate_failures: true do
        post sleep_records_url,
          params: {sleep_record: valid_attributes}, headers: valid_headers, as: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) do
        {
          user_id: non_existent_user_id
        }
      end

      let(:non_existent_user_id) { 0 }

      before do
        expect(User.where(id: non_existent_user_id)).to be_empty
      end

      it "does not create a new SleepRecord" do
        expect {
          post sleep_records_url,
            params: {sleep_record: invalid_attributes}, as: :json
        }.to change(SleepRecord, :count).by(0)
      end

      it "renders a JSON response with errors for the new sleep_record", aggregate_failures: true do
        post sleep_records_url,
          params: {sleep_record: invalid_attributes}, headers: valid_headers, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "PATCH /clock_out" do
    context "with an ongoing sleep record" do
      let!(:sleep_record) { create(:sleep_record, :ongoing) }

      before do
        expect(sleep_record.clocked_out_at).to be_nil
      end

      it "clocks out the requested sleep_record" do
        patch clock_out_sleep_record_url(sleep_record), headers: valid_headers, as: :json

        sleep_record.reload

        expect(sleep_record.clocked_out_at).to be_present
      end

      it "renders a JSON response with the sleep_record", aggregate_failures: true do
        patch clock_out_sleep_record_url(sleep_record), headers: valid_headers, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with a completed sleep record" do
      let!(:sleep_record) { create(:sleep_record, :completed) }

      it "renders a JSON response with errors for the sleep_record", aggregate_failures: true do
        patch clock_out_sleep_record_url(sleep_record), headers: valid_headers, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end
end
