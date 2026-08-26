require 'google/apis/calendar_v3'

class Sync::Calendar < Sync::Base
  EVENT_FIELDS = 'items(id,summary,htmlLink,status,start,attendees,recurringEventId),nextPageToken'

  def sync
    started_at = Time.current

    log("fetching events...")
    total = events.size
    log("#{total} events to sync")

    events.each_with_index do |event, index|
      next if event.status == "cancelled"
      next if event.recurring_event_id.present?

      occurred_at = event_time(event)
      next if occurred_at.nil?

      attendees(event).each do |attendee|
        person = find_or_create_person(attendee)
        next if person.user.present?
        register_interaction(person, event, occurred_at)
      end

      log("#{index + 1}/#{total} processed") if (index + 1) % 100 == 0
    end

    user.update(calendar_synced_at: started_at)
    log("done, #{total} events processed")
  end

  protected

  def attendees(event)
    (event.attendees || []).reject do |attendee|
      attendee.email.blank? ||
      attendee.resource ||
      attendee.self ||
      internal?(attendee.email)
    end
  end

  def find_or_create_person(attendee)
    first_name, last_name = (attendee.display_name || "").strip.split(" ", 2)
    Person.find_or_create_by_email(attendee.email, first_name: first_name, last_name: last_name, source: :calendar)
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
    @calendar_service ||= build_service(Google::Apis::CalendarV3::CalendarService)
  end

  def scopes
    [ 'https://www.googleapis.com/auth/calendar.readonly' ]
  end
end
