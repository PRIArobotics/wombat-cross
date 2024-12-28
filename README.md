# wombat-cross

A docker container for cross-compiling programs for the Wombat.

## Quick start

This container is [published on Docker Hub](https://hub.docker.com/r/sillyfreak/wombat-cross).
With [Docker](https://docs.docker.com/get-started/) installed, you can e.g. run the following:

```bash
docker run -it --rm --volume ./develop:/home/kipr:rw sillyfreak/wombat-cross \
  aarch64-linux-gnu-gcc -Wall main.c -lkipr -lm -o main -lz -lpthread
```

This will

- run the container and clean it up afterwards,
- give the container access to the `./develop` folder
- call the cross-compilation command `aarch64-linux-gnu-gcc -Wall ...` to cross-compile the C file `./develop/main.c` and store the result in `./develop/main`

You can then copy that file to your Wombat.

### Known differences from compiling with the Wombat web IDE (harrogate)

Compiling on the Wombat automatically adds the file [`_init_helper.c`](https://github.com/kipr/harrogate/blob/v1.0.0/apps/compiler/compilation-environments/c/_init_helper.c).
To my understanding, this file helps with correctly ordering output when invoking the program via the web IDE.
If you have issues with mangled output, download that file and add it to your program and compile command, e.g. like this:

```bash
docker run -it --rm --volume ./develop:/home/kipr:rw sillyfreak/wombat-cross \
  aarch64-linux-gnu-gcc -Wall main.c _init_helper.c -lkipr -lm -o main -lz -lpthread
```

## Development

This repo contains resources and scripts for building this container.
You can use them to custimize the container, or update it if this repo goes unmaintained and becomes outdated.

If you have [`just`](https://just.systems/man/en/) installed, you can get started by running e.g.

```bash
just build-docker-image
just gcc -Wall main.c -lkipr -lm -o main -lz -lpthread
```

The first command will re-build the container; the second will cross-compile just like the `docker run` command above.

Without `just`, you can still copy the commands from the Justfile to run them.
The commands are written with a Linux machine in mind; they may or may not work on other platforms.

### Preparations

> You won't need to run these steps unless this repo has become outdated.
> To simply customize the container, these steps aren't necessary.

Since it's hard to compile all libraries needed to compile Wombat programs, they are included in this repo in binary form.
To obtain them freshly, you can run the following commands:

```bash
# 1. this will download a >7GB Wombat SD card image!
just download-wombat-img
# 2. downloads KIPR's .deb packages, from which KIPR-specific libraries can be extracted
just download-libkipr
# 3. mounts the Wombat image from step 1 and copies a few select libraries from it
#    mounting requires providing admin privileges
just extract-libs
```

If you look at these scripts in the Justfile, there are a few hardcoded values:

- the Wombat image URL, including version number
- the libwallaby and create3 URLs, including version numbers and file names
- the `offset` in the `mount` command, which can be obtained via `fdisk -lu tmp/wombat.img` (after running command 1.). We're interested in the start of the second (ext4) partition.

Updating the image will require adjusting these values.

### Building the image

Using the files provided in this repo, or after running the preparation steps, you can build a docker image:

```bash
just build-docker-image
```

The image will be tagged `wombat-cross` and can then be run using that name.

### Running a container

Since the container is made for cross-compiling programs, the script adds a "volume" to the container by default.
This volume is a folder in which your program resides.
It will be made available to the container so that source files can be read and the resulting executable can be written:

```bash
# by default, a folder named "develop" is added to the container
just run
# mount a different folder
VOLUME=/some/other/folder just run

# you can also specify a command to run in the container, instead of starting a shell
just run echo "Hello World"
```

If you don't want to mount a folder or want to customize the container in other ways, copy the command directly and make your changes.

> Note that the Dockerfile sets `WORKDIR` to a place intended to mount a volume.
> You may need to change the Dockerfile and re-build the image to not mount any volume.

If you want to just compile your program, you can also use the `gcc` convenience script:

```bash
# a typical compile command
just gcc -Wall main.c -lkipr -lm -o main -lz -lpthread
```

This will call the command `aarch64-linux-gnu-gcc -Wall ...` to cross-compile the C file `./develop/main.c` (since that is the default volume) and store the result in `./develop/main`.
You can then copy that file to your Wombat.
