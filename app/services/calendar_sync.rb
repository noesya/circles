require 'google/apis/calendar_v3'

class CalendarSync
  EVENT_FIELDS = 'items(id,summary,htmlLink,status,start,attendees,recurringEventId),nextPageToken'

  attr_reader :user

  def initialize(user)
    @user = user
  end

  def sync
    started_at = Time.current

    events.each do |event|
      next if event.status == "cancelled"
      next if event.recurring_event_id.present?

      occurred_at = event_time(event)
      next if occurred_at.nil?

      attendees(event).each do |attendee|
        person = find_or_create_person(attendee)
        register_interaction(person, event, occurred_at)
      end
    end

    user.update(calendar_synced_at: started_at)
  end

  protected

  def attendees(event)
    (event.attendees || []).reject do |attendee|
      attendee.email.blank? || attendee.resource || attendee.email.casecmp?(user.email)
    end
  end

  def find_or_create_person(attendee)
    Person::Email.where(value: attendee.email).first&.person || create_person(attendee)
  end

  def create_person(attendee)
    first_name, last_name = (attendee.display_name || "").strip.split(" ", 2)
    person = Person.create(first_name: first_name, last_name: last_name)
    person.emails.create(value: attendee.email)
    person
  end

  def register_interaction(person, event, occurred_at)
    person.interactions.find_or_create_by(user: user, source_id: event.id) do |interaction|
      interaction.kind = :calendar_event
      interaction.occurred_at = occurred_at
      interaction.title = event.summary
      interaction.external_url = event.html_link
    end
  end

  def event_time(event)
    (event.start&.date_time || event.start&.date)&.to_time
  end

  def events
    unless @events
      @events = []
      page_token = nil
      loop do
        response = calendar_service.list_events(
          'primary',
          single_events: true,
          order_by: 'startTime',
          max_results: 250,
          fields: EVENT_FIELDS,
          time_min: user.calendar_synced_at&.iso8601,
          page_token: page_token
        )
        @events.concat(response.items || [])
        page_token = response.next_page_token
        break if page_token.nil?
      end
    end
    @events
  end

  def calendar_service
    unless @calendar_service
      @calendar_service = Google::Apis::CalendarV3::CalendarService.new
      @calendar_service.authorization = authorization
    end
    @calendar_service
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
    [ 'https://www.googleapis.com/auth/calendar.readonly' ]
  end
end
