FROM ruby:3.3

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    default-mysql-client \
    libmariadb-dev \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh && \
    sed -i 's/\r$//' /usr/local/bin/entrypoint.sh && \
    echo "=== entrypoint.sh line endings fixed ===" && \
    file /usr/local/bin/entrypoint.sh   

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD ["/usr/local/bin/entrypoint.sh"]