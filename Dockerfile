FROM ubuntu:focal

# username for non-root usage
ARG USERNAME=kipr
ARG UID=1000
ARG GID=${UID}

# install cross compiler & KIPR software
RUN apt update && apt install -y build-essential git binutils gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
RUN --mount=type=bind,source=deb/kipr.deb,target=/tmp/kipr.deb \
	cd /tmp/ && ar x kipr.deb data.tar.gz && \
	cd / && tar xzvf /tmp/data.tar.gz
RUN --mount=type=bind,source=deb/create3.deb,target=/tmp/create3.deb \
	cd /tmp/ && ar x create3.deb data.tar.gz && \
	cd / && tar xzvf /tmp/data.tar.gz
COPY lib/ /usr/lib/aarch64-linux-gnu/

# Create new user and home directory
RUN groupadd --gid $GID $USERNAME \
	&& useradd --uid ${GID} --gid ${UID} --create-home ${USERNAME} \
	&& mkdir -p /home/${USERNAME} \
	&& chown -R ${UID}:${GID} /home/${USERNAME}
# this could be added to give the user root access, but that's undesirable for this container
# && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
# && chmod 0440 /etc/sudoers.d/${USERNAME}

USER ${USERNAME}
WORKDIR /home/${USERNAME}
