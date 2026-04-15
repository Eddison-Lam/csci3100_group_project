FROM ruby:3.3

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    default-mysql-client \
    libmariadb-dev \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD sh -c '
    echo "=== Starting Rails in production ===" && \
    echo "RAILS_ENV          = $RAILS_ENV" && \
    echo "DATABASE_URL (first 80 chars) = ${DATABASE_URL:0:80}..." && \
    echo "RAILS_MASTER_KEY exists? = $([ -n "$RAILS_MASTER_KEY" ] && echo "YES" || echo "NO")" && \
    echo "=== Running db:migrate ===" && \
    bundle exec rails db:migrate && \
    echo "=== db:migrate completed successfully ===" && \
    echo "=== Starting Sidekiq in background ===" && \
    bundle exec sidekiq & \
    echo "=== Starting Rails server on port ${PORT} ===" && \
    exec bundle exec rails server -b 0.0.0.0 -p ${PORT}
'