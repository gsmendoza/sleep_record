require "rails_helper"

RSpec.describe "/sleep_records", type: :request do
  let(:valid_attributes) do
    {
      user_id: user.id
    }
  end

  let(:non_existent_user_id) { 0 }

  let(:invalid_attributes) do
    {
      user_id: non_existent_user_id
    }
  end

  let(:valid_headers) do
    {}
  end

  let!(:user) { create(:user) }

  before do
    expect(User.where(id: non_existent_user_id)).to be_empty
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
