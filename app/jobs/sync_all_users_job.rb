class SyncAllUsersJob < ApplicationJob

  def perform
    User.each do |user|
      SyncUserJob.perform_later(user)
    end
  end

end