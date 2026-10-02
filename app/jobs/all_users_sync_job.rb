class AllUsersSyncJob < ApplicationJob

  def perform
    User.all.each do |user|
      SyncPeopleJob.perform_later(user)
      SyncCalendarJob.perform_later(user)
      SyncMailJob.perform_later(user)
    end
  end

end
