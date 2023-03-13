if Rails.env.development?
  %i[George Lenny Leela Coleen].each do |name|
    User.create!(name: name)
  end

  user = User.first!

  starting_time = Time.utc(2023, 1, 1)

  0.upto(9) do |i|
    clocked_in_at = starting_time + i.days - 2.hours

    user.sleep_records.create!(
      clocked_in_at: clocked_in_at,
      clocked_out_at: clocked_in_at + 8.hours
    )
  end
end
