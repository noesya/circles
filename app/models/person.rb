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
  has_many  :emails, dependent: :destroy
  has_many  :phones, dependent: :destroy
  has_many :google_contacts,
            class_name: 'User::GoogleContact',
            dependent: :destroy
  has_many :interactions, dependent: :destroy
  has_one_attached :avatar

  has_and_belongs_to_many :in_users_circles,
                          class_name: 'User'

  scope :ordered, -> { order(:last_name, :first_name)}

  def to_s
    "#{first_name} #{last_name}"
  end
end
