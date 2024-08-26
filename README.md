# uv-docker-example

An example project for using uv in Dockerfiles.

See the [uv Docker integration guide](https://docs.astral.sh/uv/guides/integration/docker/) for more details.

## Trying it out

A [`run.sh`](./run.sh) utility is provided for quickly building the image and starting a container.

This script demonstrates best practices for developing using the container, using bind mounts for
the project and virtual environment directories.

To build and run the web application in the container using `docker run`:

```console
$ ./run.sh
```

Then, check out [`http://localhost:8000`](http://localhost:8000) to see the website.

To build and run the web application using Docker compose:

```
docker compose up --watch 
```

To run the command-line entrypoint in the container:

```console
$ ./run.sh hello
```

To check that the environment is up-to-date after image builds:

```console
$ ./run.sh uv sync --frozen
Audited 2 packages ...
```

To enter a `bash` shell in the container:

```console
$ ./run.sh /bin/bash
```

To build the image without running anything:

```console
$ docker build .
```

## Project overview

### Dockerfile

The [`Dockerfile`](./Dockerfile) defines the image and includes:

- Installation of uv
- Installing the project dependencies and the project separately for optimal image build caching
- Placing environment executables on the `PATH`

### Dockerignore file

The [`.dockerignore`](./.dockerignore) file includes an entry for the `.venv` directory to ensure the
`.venv` is not included in image builds. Note that the `.dockerignore` file is not applied to volume
mounts during container runs.

### Run script

The [`run.sh`](./run.sh) script includes an example of invoking `docker run` for local development,
mounting the source code for the project into the container so that edits are reflected immediately.

### Docker compose file

The [compose.yml](./compose.yml) file includes a Docker compose definition for the web application.
It includes a [`watch`
directive](https://docs.docker.com/compose/file-watch/#compose-watch-versus-bind-mounts) for Docker
compose, which is a best-practice method for updating the container on local changes.

### Application code

The Python application code for the project is at
[`src/uv_docker_example/__init__.py`](./src/uv_docker_example/__init__.py) — there's a command line
entrypoint and a basic FastAPI application — both of which just display "hello world" output.

### Project definition

The project at [`pyproject.toml`](./pyproject.toml) includes Ruff as an example development
dependency, includes FastAPI as a dependency, and defines a `hello` entrypoint for the application.
