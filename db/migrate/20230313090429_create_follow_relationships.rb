class CreateFollowRelationships < ActiveRecord::Migration[7.0]
  def change
    create_table :follow_relationships do |t|
      t.belongs_to :follower, null: false
      t.belongs_to :followee, null: false

      t.timestamps
    end

    add_foreign_key :follow_relationships, :users, column: :follower_id, primary_key: :id
    add_foreign_key :follow_relationships, :users, column: :followee_id, primary_key: :id

    add_index :follow_relationships, [:follower_id, :followee_id], unique: true
  end
end
