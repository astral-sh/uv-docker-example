#!/usr/bin/env sh
#
# Build and run the example Docker image.
#
# Mounts the local project directory to reflect a common development workflow.
#
# The `docker run` command uses the following options:
#
#   --rm                        Remove the container after exiting
#   --volume .:/app             Mount the current directory to `/app` so code changes don't require an image rebuild
#   --volume /app/.venv         Mount the virtual environment separately, so the developer's environment doesn't end up in the container
#   --publish 8000:8000         Expose the web server port 8000 to the host
#   -it $(docker build -q .)    Build the image, then use it as a run target
#   $@                          Pass any arguments to the container

if [ -t 1 ]; then
    INTERACTIVE="-it"
else
    INTERACTIVE=""
fi

docker run \
    --rm \
    --volume .:/app \
    --volume /app/.venv \
    --publish 8000:8000 \
    $INTERACTIVE \
    $(docker build -q .) \
    "$@"
