class AllUsersSyncJob < ApplicationJob

  def perform
    User.each do |user|
      SyncContactJob.perform_later(user)
      SyncCalendarJob.perform_later(user)
      SyncMailJob.perform_later(user)
    end
  end

end
