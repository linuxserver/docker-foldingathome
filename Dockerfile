FROM lsiobase/ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
ARG FOLDINGATHOME_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

#Add needed nvidia environment variables for https://github.com/NVIDIA/nvidia-docker
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

# global environment settings
ENV DEBIAN_FRONTEND="noninteractive"

RUN \
 echo "**** install runtime packages ****" && \
 apt-get update && \
 apt-get install -y \
	nvidia-opencl-dev && \
 echo "**** install foldingathome ****" && \
 if [ -z ${FOLDINGATHOME_RELEASE+x} ]; then \
 	FOLDINGATHOME_RELEASE="$(curl -sL https://download.foldingathome.org/js/fah-downloads.js \
	| awk -F'(fahclient_|_amd64.deb)' '/debian-stable-64bit/ {print $2;exit}')"; \
 fi && \
 MAJOR_VERSION="$(curl -sL https://download.foldingathome.org/js/fah-downloads.js \
	| awk -F'(/debian-stable-64bit/|/fahclient_)' '/debian-stable-64bit/ {print $2;exit}')" && \
 curl -o \
	/tmp/fah.deb -L \
	"https://download.foldingathome.org/releases/public/release/fahclient/debian-stable-64bit/${MAJOR_VERSION}/fahclient_${FOLDINGATHOME_RELEASE}_amd64.deb" && \
 dpkg -x /tmp/fah.deb /app && \
 echo "**** cleanup ****" && \
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 7396
VOLUME /config
