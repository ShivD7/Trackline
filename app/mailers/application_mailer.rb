class ApplicationMailer < ActionMailer::Base
  default from: -> { ENV.fetch("TRACKLINE_MAIL_FROM", "Trackline <no-reply@trackline.local>") }
  layout "mailer"
end
