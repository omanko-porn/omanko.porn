MASTODON_IMAGE ?= gargron/mastodon:latest

all: build

pull:
	docker pull $(MASTODON_IMAGE)

build: pull
	docker-compose build

start: build
	docker-compose up -d --scale sidekiq=2

reload:
	docker-compose restart front

assets: build
	docker-compose run --rm web rails assets:precompile

update: assets
	docker-compose run --rm web rails db:migrate
	docker-compose up -d --scale sidekiq=2 web streaming sidekiq
	make reload
	docker system prune -af

test:
	docker-compose run --rm front h2o -c /etc/h2o/h2o.conf -t

.PHONY: all pull build reload assets update test
