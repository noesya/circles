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
      @authorization = Google::Auth.get_application_default(scopes)
      @authorization.sub = user
      @authorization.fetch_access_token!
    end
    @authorization
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