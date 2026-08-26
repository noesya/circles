require "test_helper"

# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  calendar_synced_at     :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  first_name             :string
#  last_name              :string
#  mail_synced_at         :datetime
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  person_id              :uuid
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_person_id             (person_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (person_id => people.id)
#
class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
