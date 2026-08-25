class UserSync
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def sync
    PeopleSync.new(user).sync
    # CalendarSync.new(user).sync
    # MailSync.new(user).sync
  end
end
