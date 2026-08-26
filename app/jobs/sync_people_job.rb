class SyncPeopleJob < ApplicationJob

  def perform(user)
    Sync::People.new(user).sync
  end

end
