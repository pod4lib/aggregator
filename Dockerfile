FROM ruby:3.1

RUN useradd --create-home poddev

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

# Ensure latest packages for Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Allow apt to work with https-based sources
RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
    apt-transport-https \
    nodejs \
    postgresql-client \
    yarn

WORKDIR /usr/src/app

COPY --chown=poddev Gemfile Gemfile.lock ./
RUN bundle install

COPY --chown=poddev . .

USER poddev
CMD ["bundle exec rails s -b 0.0.0.0"]
ENTRYPOINT [ "/usr/src/app/docker-entrypoint.sh" ]
