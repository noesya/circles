class SyncUserJob < ApplicationJob

  def perform(user)
    PeopleSync.new(user).sync
  end

end