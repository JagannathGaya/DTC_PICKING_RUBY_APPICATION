# Matches `ruby '~> 2.6.6'` in Gemfile and `ruby 2.6.6p146` in Gemfile.lock.
# `--platform=linux/amd64` pins the image to x86_64 Linux. Without it, an
# Apple Silicon / ARM host would produce an ARM image that can't run on a
# typical x86_64 Linux server. Building on Windows (Docker Desktop) already
# defaults to amd64, so this is a no-op there.
FROM --platform=linux/amd64 ruby:2.6.6-slim-buster

# Debian 10 (buster) is end-of-life; the regular mirrors no longer serve it.
# Point apt at archive.debian.org and disable the "Valid-Until" check so
# `apt-get update` succeeds. Also drop `buster-updates` (no longer published).
RUN sed -i 's|http://deb.debian.org|http://archive.debian.org|g; s|http://security.debian.org|http://archive.debian.org|g; /buster-updates/d' /etc/apt/sources.list \
 && echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

# System packages:
#   build-essential / libpq-dev / libxml2-dev: compile native gems (pg, nokogiri)
#   postgresql-client: psql + libpq runtime
#   nodejs: required by `uglifier` to minify JS during asset compile
#   imagemagick: required by `paperclip` for image processing
#   git: bundler fetches `ar-octopus` from a git source in the Gemfile
#   tzdata: ActiveSupport timezone data
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libxml2-dev \
    postgresql-client \
    nodejs \
    imagemagick \
    git \
    tzdata \
    curl \
    dos2unix \
    shared-mime-info \
  && rm -rf /var/lib/apt/lists/*

# Pin bundler to the version that produced Gemfile.lock (BUNDLED WITH 2.1.4).
RUN gem install bundler -v '2.1.4'

# Skip the `:oracle` Bundler group (ruby-oci8 + oracle_enhanced adapter).
# Those gems require Oracle Instant Client, which isn't installed in this image.
# Postgres-backed environments work fine without them.
ENV BUNDLE_WITHOUT=oracle

WORKDIR /app

# Copy only Gemfile + lockfile first so `bundle install` is cached
# across code changes that don't touch dependencies.
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

# Now copy the rest of the application code.
COPY . .

# Cross-platform safety net for code copied from Windows hosts:
#   1. Convert any CRLF line endings in `bin/*` to LF (Bash on Linux fails on CRLF).
#   2. Restore the executable bit on Rails' `bin/*` launchers — Windows filesystems
#      don't track the Unix +x bit, so it's lost during COPY.
RUN find bin -type f -exec dos2unix {} \; \
 && chmod +x bin/*

ENV RAILS_ENV=development \
    PORT=3000 \
    BUNDLE_PATH=/usr/local/bundle

# Puma writes its pidfile here.
RUN mkdir -p tmp/pids

EXPOSE 3000

# Remove a stale server.pid (left if a prior container crashed)
# and start the Rails server bound to all interfaces so docker can reach it.
CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails server -b 0.0.0.0 -p 3000"]
