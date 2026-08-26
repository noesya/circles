class AddMailSyncedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :mail_synced_at, :datetime
  end
end
