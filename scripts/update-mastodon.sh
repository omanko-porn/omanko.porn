#!/bin/sh

cd $(dirname $0)/..

docker-compose pull
docker-compose down
docker-compose run --rm web ./bin/rails db:migrate assets:precompile
docker-compose up -d
docker-compose scale sidekiq=3
