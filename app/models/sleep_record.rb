class SleepRecord < ApplicationRecord
  scope :ongoing, -> { where(clocked_out_at: nil) }
  scope :completed, -> { where.not(id: ongoing) }

  scope :with_duration,
    -> { select("sleep_records.*, sleep_records.clocked_out_at - sleep_records.clocked_in_at AS duration") }

  belongs_to :user

  validates :user, presence: true

  validates :clocked_in_at, presence: true
  validates_datetime :clocked_in_at

  validate :ensure_user_has_no_ongoing_sleep_record, on: :create

  before_save :set_duration, if: :completed?

  def self.new_clock_in(attributes = {})
    new(attributes.merge(clocked_in_at: Time.current))
  end

  def completed?
    clocked_out_at.present?
  end

  def clock_out
    if completed?
      errors.add :base, :has_already_been_clocked_out

      false
    else
      self.clocked_out_at = Time.current
      save
    end
  end

  private

  def ensure_user_has_no_ongoing_sleep_record
    if user && user.sleep_records.ongoing.any?
      errors.add :base, :has_ongoing_sleep_record
    end
  end

  def set_duration
    self.duration = clocked_out_at - clocked_in_at
  end
end
