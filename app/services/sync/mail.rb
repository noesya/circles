require 'google/apis/gmail_v1'

class Sync::Mail < Sync::Base
  MESSAGE_FIELDS = 'id,internalDate,payload/headers'
  METADATA_HEADERS = %w[From To Cc Subject]
  EMAIL_REGEXP = /[\w.+-]+@[\w-]+\.[\w.-]+/

  def sync
    started_at = Time.current

    log("fetching messages...")
    total = messages.size
    log("#{total} messages to sync")

    messages.each_with_index do |stub, index|
      message = fetch_message(stub.id)
      next if message.nil?

      occurred_at = message_time(message)
      subject = header(message, 'Subject')
      correspondents(message).each do |email|
        person = find_or_create_person(email)
        next if person.user.present?
        register_interaction(person, message, occurred_at, subject)
      end

      log("#{index + 1}/#{total} processed") if (index + 1) % 25 == 0
    end

    user.update(mail_synced_at: started_at)
    log("done, #{total} messages processed")
  end

  protected

  def query
    parts = [ '-in:chats' ]
    parts << "after:#{user.mail_synced_at.to_i}" if user.mail_synced_at.present?
    parts.join(' ')
  end

  def correspondents(message)
    emails = %w[From To Cc].flat_map { |name| header(message, name).to_s.scan(EMAIL_REGEXP) }
    emails.map(&:downcase).uniq.reject { |email| internal?(email) }
  end

  def internal?(email)
    email.end_with?("@#{organization_domain}")
  end

  def organization_domain
    user.email.split('@').last
  end

  def find_or_create_person(email)
    Person.find_or_create_by_email(email, first_name: email.split('@').first, source: :mail)
  end

  def register_interaction(person, message, occurred_at, subject)
    person.interactions.find_or_create_by(user: user, source_id: message.id) do |interaction|
      interaction.kind = :email
      interaction.occurred_at = occurred_at
      interaction.title = subject
      interaction.external_url = "https://mail.google.com/mail/u/0/#all/#{message.id}"
    end
  end

  def header(message, name)
    message.payload&.headers&.find { |h| h.name.casecmp?(name) }&.value
  end

  def message_time(message)
    Time.at(message.internal_date / 1000.0)
  end

  def fetch_message(id)
    gmail_service.get_user_message('me', id, format: 'metadata', metadata_headers: METADATA_HEADERS, fields: MESSAGE_FIELDS)
  rescue Google::Apis::ClientError => e
    Rails.logger.warn("Sync::Mail: get_user_message failed for #{id}: #{e.message}")
    nil
  end

  def messages
    unless @messages
      @messages = []
      page_token = nil
      loop do
        response = gmail_service.list_user_messages(
          'me',
          q: query,
          max_results: 100,
          page_token: page_token
        )
        @messages.concat(response.messages || [])
        page_token = response.next_page_token
        break if page_token.nil?
      end
    end
    @messages
  end

  def gmail_service
    @gmail_service ||= build_service(Google::Apis::GmailV1::GmailService)
  end

  def scopes
    [ 'https://www.googleapis.com/auth/gmail.readonly' ]
  end
end
