# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
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
          # :registerable,
          :recoverable,
          :rememberable,
          :validatable,
          :omniauthable,
          omniauth_providers: [:saml]

  def self.from_omniauth(auth)
    User.where(email: auth.uid.downcase).first_or_create do |u|
      u.password = "#{Devise.friendly_token[0,20]}!"
    end
  end

  def to_s
    email
  end
end
