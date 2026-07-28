# An example using multi-stage image builds to create a final image without uv.

# First, build the application in the `/app` directory.
# See `Dockerfile` for details.
FROM ghcr.io/astral-sh/uv:python3.12-trixie-slim AS builder
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
    uv sync --locked --no-install-project --no-editable

# Copy only what is needed to build/install the project
COPY pyproject.toml README.md uv.lock ./
COPY src ./src
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-editable


# Then, use a final image without uv
FROM python:3.12-slim-trixie
# It is important to use the image that matches the builder, as the path to the
# Python executable must be the same, e.g., using `python:3.11-slim-trixie`
# will fail.

# Setup a non-root user with a high UID to avoid host collisions
RUN groupadd --gid 10001 app \
 && useradd --uid 10001 --gid 10001 --create-home --home-dir /home/app app

# Copy the virtual environment only (non-editable install; no source tree needed)
COPY --from=builder --chown=10001:10001 /app/.venv /app/.venv

# Place executables in the environment at the front of the path
ENV PATH="/app/.venv/bin:$PATH"

# Keeps Python from buffering stdout and stderr to avoid situations where
# the application crashes without emitting any logs due to buffering.
ENV PYTHONUNBUFFERED=1

# Use the non-root user to run our application
USER 10001

# Use `/app` as the working directory
WORKDIR /app

# Run the FastAPI application by default (installed package, not source path)
CMD ["uvicorn", "uv_docker_example:app", "--host", "0.0.0.0", "--port", "8000"]
