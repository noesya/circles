class PersonSyncJob < ApplicationJob

  def perform(person)
    PeopleSync.resync_person(person)
  end

end
