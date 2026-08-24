require 'google/apis/people_v1'

class GooglePeople
  attr_reader :user

  def initialize(user)
    @user = user
  end

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

  protected

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
      @authorization.sub = user
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