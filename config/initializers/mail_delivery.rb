require "uri"
require Rails.root.join("lib/trackline/local_mail_delivery")

ActionMailer::Base.add_delivery_method :local_file, Trackline::LocalMailDelivery

url = URI.parse(ENV.fetch("TRACKLINE_URL", "http://127.0.0.1:#{ENV.fetch('PORT', '3001')}"))
unless url.is_a?(URI::HTTP) && url.host && url.userinfo.nil? && url.path.in?([ "", "/" ]) && url.query.nil? && url.fragment.nil?
  raise "TRACKLINE_URL must be an HTTP(S) origin, for example http://127.0.0.1:3001"
end
if Rails.env.production? && !ENV["SECRET_KEY_BASE_DUMMY"] &&
    (url.scheme != "https" || ENV["SMTP_ADDRESS"].blank? || ENV["TRACKLINE_MAIL_FROM"].blank?)
  raise "Production requires an HTTPS TRACKLINE_URL, SMTP_ADDRESS, and TRACKLINE_MAIL_FROM."
end

ActionMailer::Base.default_url_options = { host: url.host, port: url.port, protocol: url.scheme }
ActionMailer::Base.raise_delivery_errors = true

unless Rails.env.test?
  if ENV["SMTP_ADDRESS"].present?
    ActionMailer::Base.delivery_method = :smtp
    ActionMailer::Base.smtp_settings = {
      address: ENV.fetch("SMTP_ADDRESS"),
      port: ENV.fetch("SMTP_PORT", "587").to_i,
      domain: ENV.fetch("SMTP_DOMAIN", url.host),
      enable_starttls_auto: true,
      open_timeout: 5,
      read_timeout: 10
    }
    if ENV["SMTP_USERNAME"].present?
      ActionMailer::Base.smtp_settings.merge!(
        user_name: ENV.fetch("SMTP_USERNAME"),
        password: ENV.fetch("SMTP_PASSWORD"),
        authentication: :plain
      )
    end
  else
    ActionMailer::Base.delivery_method = :local_file
    ActionMailer::Base.local_file_settings = { location: Rails.root.join("tmp/mail") }
  end
end
