MASTODON_IMAGE ?= gargron/mastodon:latest

all: build

pull:
	docker pull $(MASTODON_IMAGE)

build: pull
	docker-compose build

start: build
	docker-compose up -d --scale sidekiq=3

reload:
	docker-compose kill -s HUP cache
	docker-compose restart front

assets: build
	docker run \
		--env-file .env.production \
		--rm \
		-v $(shell pwd)/public/assets:/mastodon/public/assets \
		-v $(shell pwd)/public/packs:/mastodon/public/packs \
		$(MASTODON_IMAGE) rails assets:precompile

update: assets
	docker-compose stop web streaming sidekiq
	docker-compose rm -f -v web streaming sidekiq
	docker-compose run --rm web rails db:migrate
	docker-compose up -d --scale sidekiq=3 web streaming sidekiq
	make reload
	docker system prune -af

test:
	docker-compose run --rm cache nginx -t
	docker-compose run --rm front h2o -c /etc/h2o/h2o.conf -t

.PHONY: all pull build reload assets update test
