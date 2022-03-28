![CI](https://github.com/ivplus/aggregator/workflows/Ruby/badge.svg)
![tested on ruby 3](https://img.shields.io/badge/ruby-v3-red)
![tested on nodeJS 16](https://img.shields.io/badge/nodeJS-v16-blue)

# POD Aggregator
The POD Aggregator project is a Ruby on Rails application that receives and transmits MARC bibliographic and holdings data from multiple institutions.

## Developing

### Pre-requisites
This project is tested on ruby 3 and nodeJS 16. **Other versions may work but are unsupported.** JavaScript package management is done via [yarn](https://yarnpkg.com/).

### Getting started
Pull down the code and enter the project directory:
```
git clone https://github.com/ivplus/aggregator.git
cd aggregator
```
Install dependencies and prepare the database:
```sh
bin/setup
```
Create a local admin user for development:
```sh
bin/rails agg:create_admin
```

### Configurations
POD Aggregator has several configuration settings many of which are available using the [config](https://github.com/rubyconfig/config) gem at `config/settings.yml`.

### Adding data
While adding MARC data locally is perfectly fine for many development use cases, if you want to populate your local development instance with an organization and a small amount of data to get started, use the `rake db:seed` task:
```sh
bundle exec rake db:seed
```

You might want to more broadly populate the database. You can do this using the configurable `agg:seed_from_api` task that will enable you to fetch data from a running aggregator instance (production by default). You will need to add a valid API token to `config/settings.yml`. Depending on the data available, this task might load a large amount of data and take a long time:
```sh
bundle exec rake agg:seed_from_api
```

### Manually triggering normalization jobs
To generate normalized data locally you can trigger a cron job from the terminal. This will generate normalized full dumps, deletes, and deltas.

`bundle exec rails runner "GenerateFullDumpJob.enqueue_all"`


## Testing
The continuous integration tests for POD aggregator can be run using:
```sh
bundle exec rake
```

### Emulating production
While using a standard development setup locally, developers may experience some issues with read/write concurrency in Sqlite and job processing using the ActiveJob AsyncAdapter.

One solution to this is to temporarily switch to using PostgreSQL and Sidekiq with Redis locally for a more "production like" development environment. Steps:

1. In `config/cable.yml`, change the entry for development to use Redis:
```yaml
development:
  adapter: redis
  url: <%= ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" } %>
  channel_prefix: aggregator_development
```

2.  Add the following to `development.rb`:
   ```ruby
  # Use a real queuing backend for Active Job (and separate queues per environment).
  config.active_job.queue_adapter     = :sidekiq
  ```

3. Set environment variables prior to invoking the server. For now, you will need to re-export these variables in every new terminal window you open.
```sh
export REDIS_HOST=localhost
export REDIS_PORT=6379
export DATABASE_URL=postgresql://user:password@localhost:5432/dbname
bundle exec rails server  # or other commands
```

## Deployment
Deployment is setup using Capistrano using standard [Stanford Digital Library Systems and Services practices](https://github.com/sul-dlss/DeveloperPlaybook/blob/master/best-practices/deployment.md#ruby-applications).
