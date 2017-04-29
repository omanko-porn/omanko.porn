all: build

pull:
	docker-compose pull

build: pull
	docker-compose build

reload:
	docker-compose kill -s HUP nginx

test: build
	docker-compose run --rm nginx nginx -t

.PHONY: all pull build reload test
