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
#  index_user_google_contacts_on_person_id                  (person_id)
#  index_user_google_contacts_on_person_id_and_user_id      (person_id,user_id) UNIQUE
#  index_user_google_contacts_on_user_id                    (user_id)
#  index_user_google_contacts_on_user_id_and_resource_name  (user_id,resource_name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (person_id => people.id)
#  fk_rails_...  (user_id => users.id)
#
class User::GoogleContact < ApplicationRecord
  belongs_to :person
  belongs_to :user
end
