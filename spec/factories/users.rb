FactoryBot.define do
  factory :user, aliases: [:follower, :followee] do
    sequence :name
  end
end
