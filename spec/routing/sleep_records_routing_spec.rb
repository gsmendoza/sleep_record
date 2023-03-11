require "rails_helper"

RSpec.describe SleepRecordsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/sleep_records").to route_to("sleep_records#index")
    end

    it "routes to #show" do
      expect(get: "/sleep_records/1").to route_to("sleep_records#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/sleep_records").to route_to("sleep_records#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/sleep_records/1").to route_to("sleep_records#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/sleep_records/1").to route_to("sleep_records#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/sleep_records/1").to route_to("sleep_records#destroy", id: "1")
    end
  end
end
