# Shared Redis connection for the entire app.
# Before this, BookingLockService used Redis.new(...) and
# ResourceAvailabilityService used Redis.current (deprecated).
# Now both services use this single REDIS constant so we don't
# accidentally open multiple connections or hit a nil Redis.current.
REDIS = ConnectionPool::Wrapper.new(size: 5, timeout: 5) do
  redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379/0")

  options = { url: redis_url }
  options[:ssl_params] = { verify_mode: OpenSSL::SSL::VERIFY_NONE } if redis_url.start_with?("rediss")

  Redis.new(options)
end
