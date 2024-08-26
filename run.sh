#!/usr/bin/env sh

docker run --rm --volume .:/app --volume /app/.venv -it $(docker build -q .) $@
