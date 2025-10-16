#!/bin/bash
set -e

# Suppresses the error if the file doesn't exist
rm -f tmp/pids/server.pid

exec bundle exec "$@"
