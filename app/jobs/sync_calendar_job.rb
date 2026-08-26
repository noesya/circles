class SyncCalendarJob < ApplicationJob

  def perform(user)
    Sync::Calendar.new(user).sync
  end

end
