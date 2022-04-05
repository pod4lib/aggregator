FROM ruby:3.1

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

# install js engine
RUN apt-get update && apt-get install -y nodejs yarn

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD ["./bin/setup"]
