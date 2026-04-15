set -e

echo "=== Starting Rails in production ==="
echo "RAILS_ENV          = $RAILS_ENV"
echo "DATABASE_URL (first 80 chars) = ${DATABASE_URL:0:80}..."
echo "RAILS_MASTER_KEY exists? = $([ -n "$RAILS_MASTER_KEY" ] && echo "YES" || echo "NO")"

echo "=== Running db:migrate ==="
bundle exec rails db:migrate

echo "=== Starting Sidekiq in background ==="
bundle exec sidekiq &

echo "=== Starting Rails server on port ${PORT} ==="
exec bundle exec rails server -b 0.0.0.0 -p ${PORT}