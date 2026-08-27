# == Schema Information
#
# Table name: person_phones
#
#  id         :uuid             not null, primary key
#  canonical  :string
#  obsolete   :boolean          default(FALSE), not null
#  value      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  person_id  :uuid             not null
#
# Indexes
#
#  index_person_phones_on_person_id  (person_id)
#
# Foreign Keys
#
#  fk_rails_...  (person_id => people.id)
#
class Person::Phone < ApplicationRecord
  belongs_to :person

  before_validation :default_canonical

  def to_s
    "#{value}"
  end

  private

  def default_canonical
    self.canonical = value if canonical.blank?
  end
end
