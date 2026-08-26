# == Schema Information
#
# Table name: user_google_contacts
#
#  id            :uuid             not null, primary key
#  resource_name :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  person_id     :uuid             not null
#  user_id       :uuid             not null
#
# Indexes
#
#  index_user_google_contacts_on_person_id  (person_id)
#  index_user_google_contacts_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (person_id => people.id)
#  fk_rails_...  (user_id => users.id)
#
class User::GoogleContact < ApplicationRecord
  belongs_to :person
  belongs_to :user

  def self.find_or_register(person, user, resource_name)
    person.google_contacts.find_or_create_by(
      user: user,
      resource_name: resource_name
    )
  end
end
