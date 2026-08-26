class Sync::Base
  attr_reader :user

  def initialize(user)
    @user = user
  end

  protected

  def log(message)
    Rails.logger.info("[#{self.class.name}] #{user.email} — #{message}")
  end

  def build_service(service_class)
    service = service_class.new
    service.authorization = authorization
    service
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
end
