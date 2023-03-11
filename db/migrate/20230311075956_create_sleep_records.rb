class CreateSleepRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :sleep_records do |t|
      t.belongs_to :user, null: false, foreign_key: true, index: true
      t.datetime :clocked_in_at, null: false, index: true
      t.datetime :clocked_out_at, index: true

      t.timestamps
    end
  end
end
