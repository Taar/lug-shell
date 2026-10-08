# LUG-Shell

Welcome to the Hackforge Linux User Group Shell project.

## Building

There are two options to build in the project, locally or using the provided container file.

The project has the following dependencies:

- cmake
- gcc
- readline
- clang
- clang-format

### Locally

> [!NOTE]
> `readline` needs to be installed in order to build this project.
>
> For debian trixie install the `libreadline-dev` package: `apt install libreadline-dev`

The project is built using `cmake`:

```bash
# While in the project root directory
cd build && ./build.bash
```

The project can then be ran with:

```bash
cd build
./lug-shell
```

### Using the build container

> [!NOTE]
> This project uses [`podman`](https://docs.podman.io/en/latest/).
> If you want to use `docker` instead, place all occurrences of `podman` with `docker`.

The `Containerfile` is broken into a two stages. The `build` stage will install all the required packages and build the project. The `lug-shell` stage just contains the binary which is used as the main entrypoint when running the container.

```bash
podman build . -t lug-shell:latest
# or targetting the `lug-shell` stage
podman build . -t lug-shell:latest --target lug-shell
```

Once the image is built, it can be used to run the `lug-shell` program.

```bash
podman run --rm -it lug-shell
```

If the an image is built targeting the `build` stage, the binary will be built and it can be extracted from the image using a local file system mount. It can also be run using that image but it's better to use the `lug-shell` stage instead.

```bash
podman build . -t lug-shell-build:latest --target build
```

## Development

It is recommended to use the provided image and the `development` stage to hack on the LUG-Shell as it provides exactly the right environment to build and run the shell.

```bash
podman build . -t lug-shell-development:latest --target development
```

Once the image is built, mount the repository's root to `/opt` within the container. This will allow the source to be modified on the host without needed to re-build the image or re-run the container.

> [!NOTE]
> For the following commands and for non UNIX systems, `-v "$PWD:/opt"` will likely not work as the `$PWD` environment variable won't be available. If this is the case, replace it with the full path to the root of this repository.

Running the `lug-shell-development` image will run bash and set the working directory to `/opt/build` within the container. From there, run the `build.bash` script to build the project and `clean.bash` to clean the build directory.

> [!NOTE]
> `gdb` is available within the container

```bash
podman run --rm -it -v "$PWD:/opt" lug-shell-development
# Within the container
./build.bash
# or to clean
./clean.bash
```

> [!NOTE]
> Since the entire project root was mounted into the container, the build files and the binary will be available locally. The `lug-shell` _might_ run but that depends on the host system so it's best to only run it within the container.

## Clang

Check the source for errors or warnings without having to compile the project

```bash
podman build . -t lug-shell-clang:latest --target clang
podman run --rm -it -v "$PWD:/opt" lug-shell-clang
# Run against another file
# NOTE: the -- at the end is required
podman run --rm -it -v "$PWD:/opt" lug-shell-clang path/to/file/in/container.c --
```

Run the formatter on a file:

```bash
podman build . -t lug-shell-clang-format:latest --target clang-format
# This will check lugshell.c
podman run --rm -it -v "$PWD:/opt" lug-shell-clang-format
# Check another file
podman run --rm -it -v "$PWD:/opt" lug-shell-clang-format -i path/to/file/in/container.c
```

## Learning

Here is a collection of relavent manual pages and how to access them from using the `man` command.

### Using the manual image

All the manual pages can be viewed from from the `lug-shell-manual` image

> [!NOTE]
> This image is not built by default.

```bash
podman build . -t lug-shell-manual:latest --target=manual
```

Examples on how to use the image to view the manuals:

```bash
podman run --rm -it lug-shell-manual readline.3
# or
podman run --rm -it lug-shell-manual 3 readline
```

### Library Functions Manual
- `setjmp.h` - [`man setjmp.3`](https://man7.org/linux/man-pages/man3/longjmp.3.html)
- `readline/readline.h` - [`man readline.3`](https://man7.org/linux/man-pages/man3/readline.3.html)
- `readline/history.h` - [`man history.3`](https://man7.org/linux/man-pages/man3/history.3.html)
- `signal.h` - [`man signal.3`](https://man7.org/linux/man-pages/man3/signal.3p.html)
- `errno.h` - [`man errno.3`](https://man7.org/linux/man-pages/man3/errno.3.html)
  - [`strerror`](https://man7.org/linux/man-pages/man3/strerror.3.html)
- `stdio.h` - [`man stdio.3`](https://man7.org/linux/man-pages/man3/stdio.3.html)

### POSIX Programmer's Manual

- `stdlib.h` - [`man stdlib.h.0p`](https://man7.org/linux/man-pages/man0/stdlib.h.0p.html)
- `string.h` - [`man string.h.0p`](https://man7.org/linux/man-pages/man0/string.h.0p.html)
- `sys/wait.h` - [`man sys_wait.h.0p`](https://man7.org/linux/man-pages/man0/sys_wait.h.0p.html)
- `unistd.h` - [`man unistd.h.0p`](https://man7.org/linux/man-pages/man0/unistd.h.0p.html)

## Using

```bash
./build/lug-shell
# ctrl-d to exit
```
