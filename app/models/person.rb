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
class Person < ApplicationRecord
  has_many  :emails,
            dependent: :destroy

  def to_s
    "#{first_name} #{last_name}"
  end
end
