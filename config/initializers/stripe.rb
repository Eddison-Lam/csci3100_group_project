Rails.application.credentials.stripe => config

Stripe.api_key = config[:secret_key]
