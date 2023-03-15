class User < ApplicationRecord
  has_many :sleep_records, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  def friends
    self.class.where(id: friend_relationships.pluck(:followee_id))
  end

  private

  def friend_relationships
    FollowRelationship.where(
      follower: self,
      followee: followers
    )
  end

  def followers
    User.where(id: followee_relationships.pluck(:follower_id))
  end

  # Relationships where the user is the followee
  def followee_relationships
    FollowRelationship.where(followee: self)
  end
end
