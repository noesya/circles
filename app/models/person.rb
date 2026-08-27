# == Schema Information
#
# Table name: people
#
#  id                  :uuid             not null, primary key
#  company             :string
#  first_name          :string
#  hidden              :boolean          default(FALSE), not null
#  job_title           :string
#  last_interaction_at :datetime
#  last_name           :string
#  source              :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class Person < ApplicationRecord
  ACCEPTABLE_DELAY = 6.months

  enum :source, [ :contacts, :calendar, :mail ]

  has_one   :user
  has_many  :emails, dependent: :destroy
  has_many  :phones, dependent: :destroy
  has_many  :interactions, dependent: :destroy
  has_many  :google_contacts,
            class_name: 'User::GoogleContact',
            dependent: :destroy
  has_and_belongs_to_many :in_users_circles,
                          class_name: 'User'

  has_one_attached :avatar

  accepts_nested_attributes_for :emails, reject_if: proc { |attributes| attributes['value'].blank? }
  accepts_nested_attributes_for :phones, reject_if: proc { |attributes| attributes['value'].blank? }

  after_save :connect_user

  scope :ordered, -> { order(:last_name, :first_name)}
  scope :visible, -> { where(hidden: false) }
  scope :interaction_too_old, -> { where('last_interaction_at < ?', (Date.today - ACCEPTABLE_DELAY)) }
  scope :dirty, -> { where(last_name: nil) }
  scope :search, -> (query) { where("first_name ILIKE :q OR last_name ILIKE :q", q: "%#{query}%")}

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

  def email
    emails.first.value
  end

  def to_s
    first_name.present? ? "#{first_name} #{last_name}"
                        : "#{email}"
  end

  protected

  def connect_user
    user = User.where(email: emails.collect(&:value)).first
    return if user.nil?
    user.update(person: self)
  end
end
