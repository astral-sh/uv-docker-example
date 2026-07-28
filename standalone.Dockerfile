# An example of using standalone Python builds with multistage images.

# First, build the application in the `/app` directory
FROM ghcr.io/astral-sh/uv:trixie-slim AS builder
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy

# Omit development dependencies
ENV UV_NO_DEV=1

# Configure the Python directory so it is consistent
ENV UV_PYTHON_INSTALL_DIR=/python

# Only use the managed Python version
ENV UV_PYTHON_PREFERENCE=only-managed

# Install Python before the project for caching
RUN uv python install 3.12

WORKDIR /app
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=README.md,target=README.md \
    uv sync --locked --no-install-project --no-editable

# Copy only what is needed to build/install the project
COPY src ./src
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=README.md,target=README.md \
    uv sync --locked --no-editable

# Then, use a final image without uv
FROM debian:trixie-slim

# Setup a non-root user with a high UID to avoid host collisions
RUN groupadd --gid 10001 app \
 && useradd --uid 10001 --gid 10001 --create-home --home-dir /home/app app

# Install CA certificates for outbound TLS (e.g. HTTPS clients)
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Copy the Python version
COPY --from=builder /python /python

# Copy the virtual environment only (non-editable install; no source tree needed)
COPY --from=builder --chown=10001:10001 /app/.venv /app/.venv

# If the source tree is needed, copy it from the builder image
# COPY --from=builder --chown=10001:10001 /app/src/ /app/src/

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
