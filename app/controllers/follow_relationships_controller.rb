class FollowRelationshipsController < ApplicationController
  before_action :set_follow_relationship, only: %i[show]

  def show
    render json: @follow_relationship
  end

  def create
    @follow_relationship = FollowRelationship.new(follow_relationship_params)

    if @follow_relationship.save
      render json: @follow_relationship, status: :created, location: @follow_relationship
    else
      render json: @follow_relationship.errors, status: :unprocessable_entity
    end
  end

  private

  def set_follow_relationship
    @follow_relationship = FollowRelationship.find(params[:id])
  end

  def follow_relationship_params
    params.require(:follow_relationship).permit(:follower_id, :followee_id)
  end
end
