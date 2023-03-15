FactoryBot.define do
  factory :sleep_record do
    user

    clocked_in_at { Time.utc(2023, 1, 1, 22) }

    clocked_out_at do
      clocked_in_at ? clocked_in_at + 8.hours : Time.utc(2023, 1, 2, 6)
    end

    trait :ongoing do
      clocked_in_at { Time.current - 8.hours }
      clocked_out_at { nil }
    end

    trait :completed do
      clocked_in_at { Time.utc(2023, 1, 1, 22) }
      clocked_out_at { Time.utc(2023, 1, 2, 6) }
    end

    trait :with_duration do
      transient do
        specified_duration { 0 }
      end

      clocked_in_at { Time.utc(2023, 1, 1, 22) }
      clocked_out_at { clocked_in_at + specified_duration.seconds }
    end
  end
end
