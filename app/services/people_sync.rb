require 'google/apis/people_v1'

class PeopleSync
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def sync
    list.each do |google_person|
      first_email = google_person.email_addresses&.map(&:value)&.first
      first_name = google_person.names&.first&.given_name&.titleize
      last_name = google_person.names&.first&.family_name&.titleize
      next if first_email.nil? || last_name.nil?
      all_emails = google_person.email_addresses&.map(&:value)
      # Recherche par le mail
      person_email = Person::Email.where(value: first_email).first_or_create do |person_email|
        person = Person.create first_name: first_name, last_name: last_name
        person_email.person = person
      end
      person = person_email.person
      # Ajout de tous les emails
      all_emails.each do |email|
        person.emails.where(value: email).first_or_create
      end
      # Ajout des numéros de téléphone
      next if google_person.phone_numbers.nil?
      google_person.phone_numbers.each do |phone_number|
        canonical = phone_number.canonical_form
        value = phone_number.value
        person.phones.where(canonical: canonical).first_or_create do |phone|
          phone.value = value
        end
      end
    end
  end

  protected

  def list
    unless @list
      @list = []
      @list.concat request.connections
      while next_page_token do
        @list.concat request.connections
      end
    end
    @list
  end
 
  def request
    request = people_service.list_person_connections(
      'people/me',
      person_fields: 'names,emailAddresses,phoneNumbers',
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