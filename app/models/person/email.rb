# == Schema Information
#
# Table name: person_emails
#
#  id         :uuid             not null, primary key
#  obsolete   :boolean          default(FALSE), not null
#  value      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  person_id  :uuid             not null
#
# Indexes
#
#  index_person_emails_on_person_id  (person_id)
#
# Foreign Keys
#
#  fk_rails_...  (person_id => people.id)
#
class Person::Email < ApplicationRecord
  belongs_to :person

  normalizes :value, with: ->(value) { value.to_s.strip.downcase }

  def to_s
    "#{value}"
  end
end
