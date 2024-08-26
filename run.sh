#!/usr/bin/env sh
#
# Build and run the example Docker image.
#
# Mounts the local project directory to reflect a common development workflow.


docker run \
    --rm \                           # Remove the container after exiting
    --volume .:/app \                # Mount the current directory to `/app` so code changes don't require an image rebuild
    --volume /app/.venv \            # Mount the virtual environment separately, so the developer's environment doesn't end up in the container
    -it $(docker build -q .) \       # Build the image, then use it as a run target
    $@                               # Pass any arguments to the container
