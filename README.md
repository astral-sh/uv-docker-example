# uv-docker-example

An example project for using uv in Dockerfiles.

See the [uv Docker integration guide](https://docs.astral.sh/uv/guides/integration/docker/) for more details.

## Trying it out

A [`run.sh`](./run.sh) utility is provided for quickly building the image and starting a container.

This script demonstrates best practices for developing using the container, using bind mounts for
the project and virtual environment directories.

To run the application in a container:

```console
$ ./run.sh hello
```

To enter a Python REPL in a container:

```console
$ ./run.sh
```

To enter a `bash` shell in a container:

```console
$ ./run.sh /bin/bash
```

To check that the environment is up-to-date:

```console
$ ./run.sh uv sync --frozen
Audited 2 packages ...
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

The [run script](./run.sh) includes an example of invoking `docker run` for local development,
mounting the source code for the project into the container so that edits are reflected immediately.

### Application code

The Python application code for the project is at
[`src/uv_docker_example/__init__.py`](./src/uv_docker_example/__init__.py) — it just prints hello
world.

### Project definition

The project at [`pyproject.toml`](./pyproject.toml) includes includes Ruff as an example development
dependency and defines a `hello` entrypoint for the application.
