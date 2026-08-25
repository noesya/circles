require "test_helper"

# == Schema Information
#
# Table name: person_emails
#
#  id         :uuid             not null, primary key
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
class Person::EmailTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
