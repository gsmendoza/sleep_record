class FollowRelationship < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followee, class_name: "User"

  validates :follower, presence: true
  validates :followee, presence: true

  validate :ensure_uniqueness

  private

  def ensure_uniqueness
    if self.class.where(follower: follower, followee: followee).any?
      errors.add :base, :taken
    end
  end
end
