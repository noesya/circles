require "test_helper"

# == Schema Information
#
# Table name: people
#
#  id         :uuid             not null, primary key
#  company    :string
#  first_name :string
#  job_title  :string
#  last_name  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class PersonTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
