require "rails_helper"

RSpec.describe SleepRecord, type: :model do
  describe "#valid?" do
    subject(:is_valid) { sleep_record.valid? }

    let!(:user) { create(:user) }

    let(:sleep_record) do
      build(:sleep_record, user: user)
    end

    describe "concerning ongoing sleep records" do
      context "when the sleep record is new" do
        let(:sleep_record) { build(:sleep_record, user: user) }

        context "when the user does not have an ongoing sleep record" do
          before do
            expect(user.sleep_records).to be_empty
          end

          it { is_expected.to be_truthy }

          context "when another user has an ongoing sleep record" do
            let!(:another_user_ongoing_sleep_record) do
              create(:sleep_record, :ongoing, user: create(:user))
            end

            it { is_expected.to be_truthy }
          end

          context "when the user has a past completed sleep record" do
            let!(:completed_sleep_record) { create(:sleep_record, :completed, user: user) }

            it { is_expected.to be_truthy }
          end
        end

        context "when the user has an ongoing sleep record" do
          let!(:ongoing_sleep_record) { create(:sleep_record, :ongoing, user: user) }

          it { is_expected.to be_falsey }
        end
      end

      context "when the sleep record is saved and ongoing" do
        let!(:sleep_record) { create(:sleep_record, :ongoing) }

        it { is_expected.to be_truthy }
      end
    end
  end

  describe ".ongoing" do
    subject(:ongoing_sleep_records) { described_class.ongoing }

    context "when an sleep record is ongoing" do
      let!(:sleep_record) do
        create(:sleep_record, :ongoing)
      end

      it "is expected to include the sleep record" do
        expect(ongoing_sleep_records).to include(sleep_record)
      end
    end

    context "when an sleep record is not ongoing" do
      let!(:sleep_record) { create(:sleep_record, :completed) }

      it "is not expected to include the sleep record" do
        expect(ongoing_sleep_records).not_to include(sleep_record)
      end
    end
  end

  describe ".new_clock_in" do
    let(:user) { create(:user) }

    it "builds a new sleep record with the clocked_in_at set to the current time" do
      sleep_record = described_class.new_clock_in

      expect(sleep_record.clocked_in_at).to be_present
    end

    it "sets the sleep record's attributes to the arguments" do
      sleep_record = described_class.new_clock_in(user: user)

      expect(sleep_record.user).to eq(user)
    end
  end

  describe "#clock_out" do
    context "when the sleep record is ongoing" do
      let!(:sleep_record) { create(:sleep_record, :ongoing) }

      before do
        expect(sleep_record.clocked_out_at).to be_nil
      end

      it "sets the clock out to the current time", :aggregate_failures do
        expect(sleep_record.clock_out).to be_truthy

        sleep_record.reload
        expect(sleep_record.clocked_out_at).to be_present
      end
    end

    context "when the sleep record is completed" do
      let(:clocked_in_at) { Time.utc(2023, 1, 1, 22) }
      let(:clocked_out_at) { clocked_in_at + 8.hours }

      let!(:sleep_record) do
        create(:sleep_record,
          clocked_in_at: clocked_in_at,
          clocked_out_at: clocked_out_at)
      end

      it "returns false", aggregate_failures: true do
        expect(sleep_record.clock_out).to be_falsey

        expect(sleep_record.errors[:base]).to include("has already been clocked out")
        expect(sleep_record.clocked_out_at).to eq(clocked_out_at)
      end
    end
  end
end
