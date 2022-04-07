FROM ruby:3.1

RUN useradd --create-home poddev

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

# install js engine
RUN apt-get update && apt-get install -y nodejs yarn

WORKDIR /usr/src/app

COPY --chown=poddev Gemfile Gemfile.lock ./
RUN bundle install

COPY --chown=poddev . .

USER poddev
CMD ["./bin/setup"]
ENTRYPOINT [ "/usr/src/app/docker-entrypoint.sh" ]
