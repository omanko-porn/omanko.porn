MASTODON_IMAGE ?= tootsuite/mastodon:edge

all: build

pull:
	docker pull $(MASTODON_IMAGE)

build: pull
	docker-compose build

start: build
	docker-compose up -d

reload:
	docker-compose kill -s HUP front

assets: build
	docker-compose run --rm web ./bin/rails assets:precompile

update: assets
	docker-compose run --rm web ./bin/rails db:migrate
	docker-compose up -d web streaming sidekiq_default sidekiq_push_and_pull sidekiq_mailers
	make reload
	docker system prune -af

test:
	docker-compose run --rm front h2o -c /etc/h2o/h2o.conf -t

.PHONY: all pull build reload assets update test
