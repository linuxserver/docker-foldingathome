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
ENV DEBIAN_FRONTEND="noninteractive" \
    MAJOR_VERSION=7.6

RUN \
 echo "**** install runtime packages ****" && \
 apt-get update && \
 apt-get install -y \
	libnvidia-compute-435 \
	jq \
	ocl-icd-libopencl1 && \
 ln -s libOpenCL.so.1 /usr/lib/x86_64-linux-gnu/libOpenCL.so && \
 echo "**** install foldingathome ****" && \
 download_url=$(curl -sL https://download.foldingathome.org/releases.py?series=${MAJOR_VERSION} | jq -r '.[] | select(.title=="64bit Linux") | .groups[0].files[0].url') && \
 curl -o \
	/tmp/fah.deb -L \
	${download_url} && \
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
