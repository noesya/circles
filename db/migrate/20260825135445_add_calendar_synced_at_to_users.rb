class AddCalendarSyncedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :calendar_synced_at, :datetime
  end
end
