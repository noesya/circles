# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  calendar_synced_at     :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  first_name             :string
#  last_name              :string
#  mail_synced_at         :datetime
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  devise  :database_authenticatable,
          :rememberable,
          :omniauthable,
          omniauth_providers: [:saml]

  has_and_belongs_to_many :people_in_circle,
                          class_name: 'Person',
                          foreign_key: :user_id
  has_many :google_contacts,
            dependent: :destroy
  has_many :people_imported,
            -> { distinct }, 
            class_name: 'Person',
            through: :google_contacts,
            source: :person
  has_many :interactions, dependent: :destroy
  has_many :people_with_interactions,
            -> { distinct }, 
            class_name: 'Person',
            through: :interactions,
            source: :person

  scope :ordered, -> { order(:last_name, :first_name)}

  def self.from_omniauth(auth)
    user = User.where(email: auth.uid.downcase).first_or_initialize do |u|
      u.password = "#{Devise.friendly_token[0,20]}!"
    end
    user.first_name = auth.info.first_name if auth.info.first_name.present?
    user.last_name = auth.info.last_name if auth.info.last_name.present?
    user.save
    user
  end

  def person_in_my_circle?(person)
    people_in_circle.where(id: person.id).exists?
  end

  def add(person)
    return if person_in_my_circle?(person)
    people_in_circle << person
  end

  def remove(person)
    return unless person_in_my_circle?(person)
    people_in_circle.delete(person)
  end

  def to_s
    first_name.present? ? "#{first_name} #{last_name}" : "#{email}"
  end
end
