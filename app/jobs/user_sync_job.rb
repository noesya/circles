class UserSyncJob < ApplicationJob

  def perform(user)
    UserSync.new(user).sync
  end

end
