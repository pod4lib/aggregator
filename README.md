![CI](https://github.com/ivplus/aggregator/workflows/Ruby/badge.svg)

# POD Aggregator

The POD Aggregator project is a Ruby on Rails application that receives and transmits MARC bibliographic and holdings data from multiple institutions.

## Pre-requisites
Ruby 2.7.x, [yarn](https://yarnpkg.com/)


## Getting started
```
$ ruby --version
# ruby 2.7.x

$ git clone https://github.com/ivplus/aggregator.git
$ cd aggregator

$ bin/setup

$ bin/rails console
# Running via Spring preloader in process 96719
# Loading development environment (Rails 6.0.3.3)
# irb(main):001:0>
```

### Creating a local admin user

```sh
$ bin/rails agg:create_admin
```

### Configurations

POD Aggregator has several configuration settings many of which are available using the [config](https://github.com/rubyconfig/config) gem at `config/settings.yml`.

### Hydrating your local lake

While adding MARC data locally is perfectly fine for many development use cases, you may want to more broadly hydrate your data lake. You can do this using the configurable `db:seed` task.

```sh
$ bundle exec rake db:seed
```

## Testing

The continuous integration tests for POD aggregator can be run using:

```sh
$ bundle exec rake
```

## Local production-like setup

While using a standard development setup locally, developers may experience some issues with read/write concurrency in Sqlite and job processing using the ActiveJob AsyncAdapter. One solution to this is to temporarily switch to using PostgreSQL and Sidekiq with Redis locally for a more "production like" development environment.

## Deployment

Deployment is setup using Capistrano using standard [Stanford Digital Library Systems and Services practices](https://github.com/sul-dlss/DeveloperPlaybook/blob/master/best-practices/deployment.md#ruby-applications).
