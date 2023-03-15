class User < ApplicationRecord
  has_many :sleep_records, dependent: :destroy

  # Relationships where the user is the followee
  has_many :followee_relationships,
    class_name: "FollowRelationship",
    foreign_key: "followee_id",
    inverse_of: :followee,
    dependent: :destroy

  has_many :followers, through: :followee_relationships, class_name: "User", foreign_key: "follower_id"

  # Relationships where the user is the follower
  has_many :follower_relationships,
    class_name: "FollowRelationship",
    foreign_key: "follower_id",
    inverse_of: :follower,
    dependent: :destroy

  validates :name, presence: true, uniqueness: true

  def friends
    self.class.where(id: friend_relationships.pluck(:followee_id))
  end

  private

  def friend_relationships
    follower_relationships.where(followee: followers)
  end
end
