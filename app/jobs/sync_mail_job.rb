class SyncMailJob < ApplicationJob

  def perform(user)
    Sync::Mail.new(user).sync
  end

end
