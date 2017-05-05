all: build

pull:
	docker-compose pull

build: pull
	docker-compose build

reload:
	docker-compose kill -s HUP nginx

update:
	docker pull gargron/mastodon:latest
	docker run \
		--env-file .env.production \
		--rm \
		-v $(pwd)/public/assets:/mastodon/public/assets \
		-v $(pwd)/public/packs:/mastodon/public/packs \
		gargron/mastodon:latest rails assets:precompile
	docker-compose stop web streaming sidekiq
	docker-compose rm -f -v web streaming sidekiq
	docker-compose run --rm web rails db:migrate
	docker-compose up -d web streaming sidekiq
	docker-compose scale sidekiq=3
	docker-compose kill -s HUP nginx

test:
	docker-compose run --rm nginx nginx -t

.PHONY: all pull build reload update test
