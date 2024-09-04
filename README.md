# uv-docker-example

An example project for using uv in Docker images, with a focus on best practices for developing with
the project mounted in the local image.

See the [uv Docker integration guide](https://docs.astral.sh/uv/guides/integration/docker/) for more
background.

## Trying it out

A [`run.sh`](./run.sh) utility is provided for quickly building the image and starting a container.
This script demonstrates best practices for developing using the container, using bind mounts for
the project and virtual environment directories.

To build and run the web application in the container using `docker run`:

```console
$ ./run.sh
```

Then, check out [`http://localhost:8000`](http://localhost:8000) to see the website.

A Docker compose configuration is also provided to demonstrate best practices for developing using
the container with Docker compose. Docker compose is more complex than using `docker run`, but has
more robust support for various workflows.

To build and run the web application using Docker compose:

```
docker compose up --watch 
```

By default, the image is set up to start the web application. However, a command-line interface is
provided for demonstration purposes as well. 

To run the command-line entrypoint in the container:

```console
$ ./run.sh hello
```

## Project overview

### Dockerfile

The [`Dockerfile`](./Dockerfile) defines the image and includes:

- Installation of uv
- Installing the project dependencies and the project separately for optimal image build caching
- Placing environment executables on the `PATH`
- Running the web application

The [`Dockerfile.multistage`](./Dockerfile.multistage) example extends the `Dockerfile` example to
use multistage builds to reduce the final size of the image.

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

## Useful commands

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

To build the multistage image:

```console
$ docker build . --file Dockerfile.multistage
```
