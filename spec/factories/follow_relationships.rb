FactoryBot.define do
  factory :follow_relationship do
    follower { create(:user) }
    followee { create(:user) }
  end
end
