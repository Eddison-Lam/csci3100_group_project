FROM ruby:3.3

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    default-mysql-client \
    libmariadb-dev \
    nodejs

WORKDIR /app

RUN gem install rails

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD ["rails", "server", "-b", "0.0.0.0"]
