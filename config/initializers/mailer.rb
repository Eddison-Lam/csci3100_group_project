Rails.application.configure do
  next if Rails.env.test?
  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
    address:              "smtp.sendgrid.net",
    port:                 587,
    domain:               Rails.env.production? ? (ENV["DOMAIN"] || "cuhk-booking.edu.hk") : "localhost",
    user_name:            Rails.application.credentials.sendgrid[:username],
    password:             Rails.application.credentials.sendgrid[:password],
    authentication:       :plain,
    enable_starttls_auto: true
  }

  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
end
