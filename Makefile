all: build

pull:
	docker-compose pull

build: pull
	docker-compose build

test: build
	docker-compose run --rm nginx nginx -t

.PHONY: all build test
