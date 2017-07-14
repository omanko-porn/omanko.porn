MASTODON_IMAGE ?= gargron/mastodon:latest

all: build

pull:
	docker-compose pull

build: pull
	docker-compose build

start: build
	docker-compose up -d
	docker-compose scale sidekiq=3

reload:
	docker-compose kill -s HUP nginx

update:
	docker pull $(MASTODON_IMAGE)
	touch public/sw.js
	docker run \
		--env-file .env.production \
		--rm \
		-v $(shell pwd)/public/sw.js:/mastodon/public/sw.js \
		-v $(shell pwd)/public/assets:/mastodon/public/assets \
		-v $(shell pwd)/public/packs:/mastodon/public/packs \
		$(MASTODON_IMAGE) rails assets:precompile
	docker-compose stop web streaming sidekiq
	docker-compose rm -f -v web streaming sidekiq
	docker-compose run --rm web rails db:migrate
	docker-compose up -d web streaming sidekiq
	docker-compose scale sidekiq=3
	docker-compose kill -s HUP nginx

test:
	docker-compose run --rm nginx nginx -t

.PHONY: all pull build reload update test
