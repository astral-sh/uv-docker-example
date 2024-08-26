FROM python:3.12-slim-bookworm

# Install uv
COPY --from=ghcr.io/astral-sh/uv:0.3.3 /uv /bin/uv

# Install the project with intermediate layers
ADD .dockerignore .

# First, install the dependencies
WORKDIR /app
ADD uv.lock /app/uv.lock
ADD pyproject.toml /app/pyproject.toml
RUN uv sync --frozen --no-install-project

# Then, install the rest of the project
ADD . /app
RUN uv sync --frozen

# Place executables in the environment at the front of the path
ENV PATH="/app/.venv/bin:$PATH"
