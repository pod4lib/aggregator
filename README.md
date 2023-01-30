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

To more broadly populate the database, use the configurable `agg:seed_from_api` task. This will enable fetching data from a running aggregator instance (production by default). The configuration file `config/settings.yml` controls what data gets pulled with the agg:seed_from_api task. Add a valid API token to the settings.yml file in the token field under `marc_seed_fixtures` and update the list of organizations to import data from as necessary.

Depending on the data available, this task might load a large amount of data and take a long time:
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

One solution to this is to temporarily switch to using PostgreSQL and Sidekiq with Redis locally for a more "production like" development environment. To do this:

Set environment variables prior to invoking the server. For now, you will need to re-export these variables in every new terminal window you open.
```sh
export SIDEKIQ_REDIS_URL=redis://localhost:6379/0
export DATABASE_URL=postgresql://user:password@localhost:5432/dbname
bin/dev  # or other commands
```

## Deployment
Deployment is setup using Capistrano using standard [Stanford Digital Library Systems and Services practices](https://github.com/sul-dlss/DeveloperPlaybook/blob/master/best-practices/deployment.md#ruby-applications).

## With Docker

### Initial Setup:
1. `docker compose up -d`
2. `docker compose exec aggapp ./bin/setup`
3. Create an admin user: `docker compose exec aggapp ./bin/rails agg:create_admin`

### Stopping and Starting:
Start the stack with:
1. `docker compose up -d`

Stop the stack with:
2. `docker compose down`

### Managing Data:
Data for the redis and postgres services are persisted using docker named volumes. You can see what volumes are currently present with:
`docker volume ls`
If you want to remove a volume (e.g. to start with a fresh database or redis cache), you can do:
`docker volume rm aggregator_db`
`docker volume rm aggregator_cache`

### Resetting Docker:

In some cases Docker container image versions may get stale and may need to be rebuilt with no cache. Attempt the steps in option 1 first before proceeding to option 2.

#### Option 1: Rebuild images

Step 1: Stop and remove all running docker containers for POD
```
docker compose down
```

Step 2: Rebuild docker images with no cache
```
docker compose build --no-cache
```

Step 3: Restart containers
```
docker compose up -d
```

#### Option 2: System prune

To completely remove all docker containers and images from the system, run the system prune command.

Step 1: System prune

Warning: The system prune command will remove all containers and images from the system.
```
docker system prune -a -f
docker ps -aq
docker compose pull
```

Optionally, to also remove all volumes, the system prune command can be run with the `--volumes` option. Warning: The volumes option will remove all named volumes and all local data will be deleted. The data seeds will need to be run again if the volumes are purged. 
```
docker system prune -a -f --volumes
```

### Logs:
To check the log output of a container run the command `docker logs ${container_name}` e.g.:
`docker logs aggapp`

## Development Standards

### Display dates

Dates are displayed in a standard format on all UI pages across the application. The `local_time` library accepts a date in UTC and automatically detects the user's timezone on the client side and displays the equivalent date in the local timezone. Also there is a custom helper method `datetime_display_format()` that returns the standard date format. That way the date format can be managed centrally.

To display a date in the UI, use the `local_time` library with the `datetime_display_format` helper method.

```
<%= local_time(uploads.last.created_at, format: datetime_display_format()) %>
```


