require "test_helper"

# == Schema Information
#
# Table name: person_phones
#
#  id         :uuid             not null, primary key
#  canonical  :string
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
class Person::PhoneTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
