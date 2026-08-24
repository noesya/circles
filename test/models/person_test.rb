require "test_helper"

# == Schema Information
#
# Table name: people
#
#  id         :uuid             not null, primary key
#  first_name :string
#  last_name  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class PersonTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
