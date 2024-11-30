# wombat-cross

A docker container for cross-compiling programs for the Wombat.

## Quick start

If you have [`just`](https://just.systems/man/en/) - and, of course, [Docker](https://docs.docker.com/get-started/) - installed, you can get started by running e.g.

```bash
just build-docker-image
just gcc -Wall main.c -lkipr -lm -o main -lz -lpthread
```

This will call the command `aarch64-linux-gnu-gcc -Wall ...` to cross-compile the C file `./develop/main.c` (since that is the default volume) and store the result in `./develop/main`.
You can then copy that file to your Wombat.

## Usage

This repo contains a Dockerfile and scripts to prepare for building a docker image from it.
Without `just`, you can still copy the commands from the Justfile to run them.

The commands are written with a Linux machine in mind; they may or may not work on other platforms.

### Preparations

> You won't need to run these steps unless this repo goes unmaintained and becomes outdated.

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
- the `offset` in the `mount` command, which can be obtained via `fdisk -lu tmp/wombat.img` (after running command 1.)

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
just docker
# mount a different folder
VOLUME=/some/other/folder just docker

# you can also specify a command to run in the container, instead of starting a shell
just docker echo "Hello World"
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