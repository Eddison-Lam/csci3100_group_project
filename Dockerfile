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

RUN chmod +x bin/*

CMD echo "=== Docker CMD started ===" && \
    echo "=== Current dir: $(pwd) ===" && \
    ls -la && \
    echo "=== Starting Sidekiq ===" && \
    bundle exec sidekiq & \
    echo "=== Starting Rails server on port ${PORT} ===" && \
    bundle exec rails server -b 0.0.0.0 -p ${PORT}