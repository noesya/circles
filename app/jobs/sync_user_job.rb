class SyncUserJob < ApplicationJob

  def perform(user)
    google_people = GooglePeople.new(user.email)
    google_people.list.each do |google_person|
      first_email = google_person.email_addresses&.map(&:value)&.first
      next if first_email.nil?
      all_emails = google_person.email_addresses&.map(&:value)
      first_name = google_person.names&.first&.given_name
      last_name = google_person.names&.first&.family_name
      person_email = Person::Email.where(value: first_email).first_or_create do |person_email|
        person = Person.create first_name: first_name, last_name: last_name
        person_email.person = person
      end
      person = person_email.person
      all_emails.each do |email|
        person.emails.where(value: email).first_or_create
      end
      google_person.phone_numbers.each do |phone_number|
        canonical = google_person.phone_numbers.first.canonical_form
        value = google_person.phone_numbers.first.value
        person.phones.where(canonical: canonical).first_or_create do |phone|
          phone.value = value
        end
      end
    end
  end

end