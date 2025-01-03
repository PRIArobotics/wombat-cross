help:
	@just --list

# download a Wombat image (multiple GBs!) to extract libraries from
download-wombat-img:
	curl -o tmp/wombat.img https://files.kipr.org/wombat/Wombat_v30.3.0.img

# download the necessary KIPR libraries
download-libkipr:
	curl -Lo deb/kipr.deb https://github.com/kipr/libwallaby/releases/download/v1.0.0/kipr.deb
	curl -Lo deb/create3.deb https://github.com/kipr/create3/releases/download/v1.0.0/create3.deb

# from a downloaded Wombat image, extracts the libraries needed to cross-compile programs for the Wombat
extract-libs MOUNTPOINT='/mnt':
	sudo mount -o loop,ro,noload,offset=$((512*532480)) -t ext4 tmp/wombat.img '{{MOUNTPOINT}}'
	mkdir lib-new
	cp -P '{{MOUNTPOINT}}'/usr/lib/aarch64-linux-gnu/ld-*.so* lib-new/
	cp -P '{{MOUNTPOINT}}'/usr/lib/aarch64-linux-gnu/libbsd.so* lib-new/
	cp -P '{{MOUNTPOINT}}'/usr/lib/aarch64-linux-gnu/libmd.so* lib-new/
	cp -P '{{MOUNTPOINT}}'/usr/lib/aarch64-linux-gnu/libxcb*.so* lib-new/
	cp -P '{{MOUNTPOINT}}'/usr/lib/aarch64-linux-gnu/libz.so* lib-new/
	cp -P '{{MOUNTPOINT}}'/usr/lib/aarch64-linux-gnu/libX11.so* lib-new/
	cp -P '{{MOUNTPOINT}}'/usr/lib/aarch64-linux-gnu/libX11-xcb.so* lib-new/
	cp -P '{{MOUNTPOINT}}'/usr/lib/aarch64-linux-gnu/libXau.so* lib-new/
	cp -P '{{MOUNTPOINT}}'/usr/lib/aarch64-linux-gnu/libXdmcp.so* lib-new/
	rm -r lib
	mv lib-new lib
	sudo umount '{{MOUNTPOINT}}'

# build a Ubuntu focal image with aarch64 cross compiler and necessary libraries
build-docker-image:
	docker build -t 'wombat-cross' .

# re-tag the built image to prepend user name and push to docker hub (requires access to account sillyfreak)
push-docker-image:
	docker image tag wombat-cross:latest sillyfreak/wombat-cross
	docker push sillyfreak/wombat-cross

set positional-arguments

[doc("start a docker container for cross-compilation
	CONTAINER_NAME (=wombat_cross): the container's name, for outside access
	VOLUME (=./develop): the folder to mount inside the container, where source code resides
	ARGS: a command to run in the container; if not given, an interactive shell is started")]
run *ARGS:
	docker run -it --rm --name "${CONTAINER_NAME:-wombat_cross}" \
		--volume "${VOLUME:-./develop}":/home/kipr:rw \
		wombat-cross "$@"

[doc("run a docker container for a single cross-compilation command
	CONTAINER_NAME (=wombat_cross): the container's name, for outside access
	VOLUME (=./develop): the folder to mount inside the container, where source code resides
	ARGS: the rest of a gcc command line: `gcc {ARGS}`")]
gcc *ARGS: (run 'aarch64-linux-gnu-gcc' ARGS)

# aarch64-linux-gnu-gcc --print-file-name=libkipr.so
