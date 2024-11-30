FROM ubuntu:focal

RUN apt update && apt install -y build-essential git binutils gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
RUN --mount=type=bind,source=deb/kipr.deb,target=/tmp/kipr.deb \
	cd /tmp/ && ar x kipr.deb data.tar.gz && \
	cd / && tar xzvf /tmp/data.tar.gz
RUN --mount=type=bind,source=deb/create3.deb,target=/tmp/create3.deb \
	cd /tmp/ && ar x create3.deb data.tar.gz && \
	cd / && tar xzvf /tmp/data.tar.gz
COPY lib/ /usr/lib/aarch64-linux-gnu/
WORKDIR /root/develop
