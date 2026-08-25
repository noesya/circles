require 'google/apis/people_v1'
require 'open-uri'

class PeopleSync
  PERSON_FIELDS = 'names,emailAddresses,phoneNumbers,photos,organizations'

  def self.resync_person(person)
    person.google_contacts.any? do |google_contact|
      new(google_contact.user).resync_person(person)
    end
  end

  attr_reader :user

  def initialize(user)
    @user = user
  end

  def sync
    list.each do |google_person|
      emails = google_person.email_addresses&.map(&:value) || []
      first_name = google_person.names&.first&.given_name&.titleize
      last_name = google_person.names&.first&.family_name&.titleize
      next if emails.empty? || last_name.nil?

      person = find_or_create_person(emails, first_name, last_name)

      register_contact(person, google_person)
      sync_organization(person, google_person)
      sync_emails(person, google_person)
      sync_phones(person, google_person)
      attach_avatar(person, google_person) unless person.avatar.attached?
    end
  end

  def resync_person(person)
    contact = person.google_contacts.find_by!(user: user)
    google_person = fetch_person(contact.resource_name)
    return false if google_person.nil?
    sync_organization(person, google_person)
    sync_emails(person, google_person)
    sync_phones(person, google_person)
    true
  end

  protected

  def find_or_create_person(emails, first_name, last_name)
    Person::Email.where(value: emails).first&.person ||
      Person.create(first_name: first_name, last_name: last_name)
  end

  def register_contact(person, google_person)
    person.google_contacts.find_or_create_by(user: user, resource_name: google_person.resource_name)
  end

  def fetch_person(resource_name)
    people_service.get_person(resource_name, person_fields: PERSON_FIELDS)
  rescue Google::Apis::ClientError => e
    Rails.logger.warn("PeopleSync: get_person failed for #{resource_name}: #{e.message}")
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
    Rails.logger.warn("PeopleSync: failed to fetch avatar for person #{person.id}: #{e.message}")
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

  def list
    unless @list
      @list = []
      @list.concat(request.connections || [])
      while next_page_token do
        @list.concat(request.connections || [])
      end
    end
    @list
  end

  def request
    request = people_service.list_person_connections(
      'people/me',
      person_fields: PERSON_FIELDS,
      page_token: next_page_token
    )
    @next_page_token = request.next_page_token
    request
  end

  def next_page_token
    @next_page_token
  end

  def people_service
    unless @people_service
      @people_service = Google::Apis::PeopleV1::PeopleServiceService.new
      @people_service.authorization = authorization
    end
    @people_service
  end

  def authorization
    unless @authorization
      @authorization = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: StringIO.new(json_key),
        scope: scopes
      )
      @authorization.sub = user.email
      @authorization.fetch_access_token!
    end
    @authorization
  end

  def json_key
    @json_key ||= Base64.decode64(ENV.fetch('GOOGLE_APPLICATION_CREDENTIALS_BASE64'))
  end

  def scopes
    [
      'https://www.googleapis.com/auth/calendar.readonly',
      'https://www.googleapis.com/auth/contacts.readonly',
      'https://www.googleapis.com/auth/directory.readonly',
      'https://www.googleapis.com/auth/gmail.readonly',
    ]
  end

end
