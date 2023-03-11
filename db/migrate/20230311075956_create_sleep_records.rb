class CreateSleepRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :sleep_records do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.datetime :clocked_in_at

      t.timestamps
    end
    add_index :sleep_records, :clocked_in_at
  end
end
