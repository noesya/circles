class AllUsersSyncJob < ApplicationJob

  def perform
    User.each do |user|
      UserSyncJob.perform_later(user)
    end
  end

end
