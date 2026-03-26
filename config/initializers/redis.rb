# Shared Redis connection for the entire app.
# Before this, BookingLockService used Redis.new(...) and
# ResourceAvailabilityService used Redis.current (deprecated).
# Now both services use this single REDIS constant so we don't
# accidentally open multiple connections or hit a nil Redis.current.
REDIS = Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))
