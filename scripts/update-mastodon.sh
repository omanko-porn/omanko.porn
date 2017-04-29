#!/bin/sh

set -ex

cd $(dirname $0)/..

docker-compose pull web streaming sidekiq
docker-compose stop web streaming sidekiq
docker-compose rm -f -v web streaming sidekiq
docker-compose run --rm web ./bin/rails db:migrate assets:precompile
docker-compose up -d web streaming sidekiq
docker-compose scale sidekiq=3
docker-compose kill -s HUP nginx
