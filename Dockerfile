FROM ruby:2.2

ENV BUNDLER_VERSION=1.17.3 \
    APP_HOME=/app \
    RAILS_ENV=development \
    RACK_ENV=development \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="test:production"

RUN rm -f /etc/apt/sources.list /etc/apt/sources.list.d/* \
  && printf "deb [trusted=yes] http://archive.debian.org/debian jessie main\n" > /etc/apt/sources.list \
  && printf 'Acquire::Check-Valid-Until "false";\nAcquire::AllowInsecureRepositories "true";\n' > /etc/apt/apt.conf.d/99no-check-valid-until \
  && apt-get -o Acquire::Check-Valid-Until=false -o Acquire::AllowInsecureRepositories=true update -y \
  && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libpq-dev \
    postgresql-client \
    imagemagick \
    libmagickwand-dev \
    libxml2-dev \
    libxslt1-dev \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN gem install bundler -v "$BUNDLER_VERSION"

WORKDIR $APP_HOME

COPY Gemfile Gemfile.lock* ./
RUN bundle install

COPY . .

COPY docker/entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint

EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/entrypoint"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
