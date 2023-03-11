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
end
