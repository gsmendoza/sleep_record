FactoryBot.define do
  factory :user, aliases: [:follower, :followee] do
    sequence :name

    trait :friend do
      transient do
        friend { create(:user) }
      end

      after(:create) do |user, evaluator|
        create(:follow_relationship, follower: user, followee: evaluator.friend)
        create(:follow_relationship, follower: evaluator.friend, followee: user)
      end
    end
  end
end
