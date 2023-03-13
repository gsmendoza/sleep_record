class FollowRelationship < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followee, class_name: "User"

  validates :follower, presence: true, uniqueness: {scope: :followee_id}
  validates :followee, presence: true, uniqueness: {scope: :follower_id}
end
