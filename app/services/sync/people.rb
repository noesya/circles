require 'google/apis/people_v1'
require 'open-uri'

class Sync::People < Sync::Base
  PERSON_FIELDS = 'names,emailAddresses,phoneNumbers,photos,organizations'

  def sync
    log("fetching contacts...")
    total = people.size
    log("#{total} contacts to sync")

    people.each_with_index do |google_person, index|
      emails = google_person.email_addresses&.map(&:value) || []
      first_name = google_person.names&.first&.given_name&.titleize
      last_name = google_person.names&.first&.family_name&.titleize
      next if emails.empty? || last_name.nil?

      person = Person.find_or_create_by_email(emails, first_name: first_name, last_name: last_name, source: :contacts)

      register_contact(person, google_person)
      sync_organization(person, google_person)
      sync_emails(person, google_person)
      sync_phones(person, google_person)
      attach_avatar(person, google_person) unless person.avatar.attached?

      log("#{index + 1}/#{total} processed") if (index + 1) % 100 == 0
    end

    log("done, #{total} contacts processed")
  end

  protected

  def register_contact(person, google_person)
    User::GoogleContact.find_or_register(person, user, google_person.resource_name)
  end

  def fetch_person(resource_name)
    people_service.get_person(resource_name, person_fields: PERSON_FIELDS)
  rescue Google::Apis::ClientError => e
    Rails.logger.warn("Sync::People: get_person failed for #{resource_name}: #{e.message}")
    nil
  end

  def sync_organization(person, google_person)
    organization = google_person.organizations&.first
    return if organization.nil?
    person.update_column :job_title, organization.title if person.job_title.blank?
    person.update_column :company, organization.name if person.company.blank?
  end

  def sync_emails(person, google_person)
    (google_person.email_addresses&.map(&:value) || []).each do |email|
      person.emails.where(value: email).first_or_create
    end
  end

  def sync_phones(person, google_person)
    (google_person.phone_numbers || []).each do |phone_number|
      person.phones.where(canonical: phone_number.canonical_form).first_or_create do |phone|
        phone.value = phone_number.value
      end
    end
  end

  AVATAR_SIZE = 500
  GOOGLE_SIZE_SUFFIX = /=s\d+(-c)?\z/

  def attach_avatar(person, google_person)
    photo_url = google_person.photos&.find { |photo| !photo.default }&.url
    return if photo_url.nil?

    person.avatar.attach(
      io: URI.open(resized_photo_url(photo_url)),
      filename: "#{person.id}-avatar.jpg"
    )
  rescue OpenURI::HTTPError, SocketError, Timeout::Error => e
    Rails.logger.warn("Sync::People: failed to fetch avatar for person #{person.id}: #{e.message}")
  end

  # Le CDN googleusercontent.com lit la taille dans un suffixe `=sNN(-c)`
  # de l'URL ; un `?sz=` derrière ce suffixe est ignoré.
  def resized_photo_url(url)
    if url.match?(GOOGLE_SIZE_SUFFIX)
      url.sub(GOOGLE_SIZE_SUFFIX, "=s#{AVATAR_SIZE}-c")
    else
      separator = url.include?("?") ? "&" : "?"
      "#{url}#{separator}sz=#{AVATAR_SIZE}"
    end
  end

  def people
    unless @people
      @people = []
      page_token = nil
      loop do
        response = people_service.list_person_connections(
          'people/me',
          person_fields: PERSON_FIELDS,
          page_token: page_token
        )
        @people.concat(response.connections || [])
        page_token = response.next_page_token
        break if page_token.nil?
      end
    end
    @people
  end

  def people_service
    @people_service ||= build_service(Google::Apis::PeopleV1::PeopleServiceService)
  end

  def scopes
    [ 'https://www.googleapis.com/auth/contacts.readonly' ]
  end
end
