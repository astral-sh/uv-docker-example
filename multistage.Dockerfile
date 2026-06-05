# An example using multi-stage image builds to create a final image without uv.

# Note: spec `major.minor` versions ONLY for uv Python images.
ARG PYTHON_VERSION=3.12
ARG DEBIAN_CODENAME=trixie
ARG VARIANT=slim

# First, build the application in the `/app` directory.
# See `Dockerfile` for details.
FROM ghcr.io/astral-sh/uv:python${PYTHON_VERSION}-${DEBIAN_CODENAME}-${VARIANT} AS builder
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy

# Omit development dependencies
ENV UV_NO_DEV=1

# Disable Python downloads, because we want to use the system interpreter
# across both images. If using a managed Python version, it needs to be
# copied from the build image into the final image; see `standalone.Dockerfile`
# for an example.
ENV UV_PYTHON_DOWNLOADS=0

WORKDIR /app
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project
COPY . /app
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked


# Then, use a final image without uv
FROM python:${PYTHON_VERSION}-${VARIANT}-${DEBIAN_CODENAME}
# [Important] The image tag format differs between the official Python image and
# uv-provided images.
#
# Official Python image  →  python:<major>.<minor>.<patch>-<variant>-<codename>
# uv Python image        →  python<major>.<minor>-<codename>-<variant>
#
# Do NOT copy-paste tags between the two — they are not interchangeable.
# Reference the official docs for both definitions.

# Setup a non-root user
RUN groupadd --system --gid 999 nonroot \
 && useradd --system --gid 999 --uid 999 --create-home nonroot

# Copy the application from the builder
COPY --from=builder --chown=nonroot:nonroot /app /app

# Place executables in the environment at the front of the path
ENV PATH="/app/.venv/bin:$PATH"

# Keeps Python from buffering stdout and stderr to avoid situations where
# the application crashes without emitting any logs due to buffering.
ENV PYTHONUNBUFFERED=1

# Use the non-root user to run our application
USER nonroot

# Use `/app` as the working directory
WORKDIR /app

# Run the FastAPI application by default
CMD ["fastapi", "run", "--host", "0.0.0.0", "src/uv_docker_example"]
