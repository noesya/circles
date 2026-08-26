# == Schema Information
#
# Table name: people
#
#  id         :uuid             not null, primary key
#  company    :string
#  first_name :string
#  hidden     :boolean          default(FALSE), not null
#  job_title  :string
#  last_name  :string
#  source     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Person < ApplicationRecord
  enum :source, [ :contacts, :calendar, :mail ]

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
  scope :visible, -> { where(hidden: false) }

  def self.find_or_create_by_email(*emails, first_name: nil, last_name: nil, source: nil)
    emails = emails.flatten.compact
    person = Email.where(value: emails).first&.person
    return person if person

    person = create(first_name: first_name, last_name: last_name, source: source)
    emails.each { |email| person.emails.find_or_create_by(value: email) }
    person
  end

  def status
    "#{job_title} #{company}"
  end

  def to_s
    "#{first_name} #{last_name}"
  end
end
