# uv-docker-example

An example project for using uv in Dockerfiles.

See the [uv Docker integration guide](https://docs.astral.sh/uv/guides/integration/docker/) for more details.

## Running the image

A [`run.sh`](./run.sh) utility is provided for quickly building the image and starting a container.

This script demonstrates best practices for developing using the container, using bind mounts for
the project and virtual environment directories.

To run the application in an image:

```
./run.sh hello
```

To enter a Python REPL in the image:

```
./run.sh
```

To enter a `bash` shell in the image:

```
./run.sh /bin/bash
```
