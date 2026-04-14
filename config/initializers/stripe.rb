unless Rails.env.test?
  config = Rails.application.credentials.stripe
  Stripe.api_key = config[:secret_key]
end