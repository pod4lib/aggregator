FROM ruby:3.4

RUN useradd --create-home poddev

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

# Allow apt to work with https-based sources
RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
    apt-transport-https \
    nodejs \
    postgresql-client

WORKDIR /usr/src/app

COPY --chown=poddev Gemfile Gemfile.lock ./
RUN bundle install

COPY --chown=poddev . .

USER poddev
CMD ["BINDING=0.0.0.0 bin/dev"]
ENTRYPOINT [ "/usr/src/app/docker-entrypoint.sh" ]
