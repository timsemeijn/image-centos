## -*- docker-image-name: "scaleway/centos:latest" -*-
FROM multiarch/centos:7.2.1511-amd64-clean
# following 'FROM' lines are used dynamically thanks do the image-builder
# which dynamically update the Dockerfile if needed.
#FROM multiarch/centos:7.2.1511-armhfp-clean    # arch=armv7l
#FROM multiarch/centos:7.2.1511-aarch64-clean   # arch=arm64
#FROM multiarch/centos:7.2.1511-i386-clean      # arch=i386
#FROM multiarch/centos:7.2.1511-ppc64-clean     # arch=ppc64
#FROM multiarch/centos:7.2.1511-ppc64le-clean   # arch=ppc64le


# Environment
ENV SCW_BASE_IMAGE scaleway/centos:latest


# Adding and calling builder-enter
COPY ./overlay-${ARCH}/etc/yum.repos.d/ /etc/yum.repos.d/
COPY ./overlay-image-tools/usr/local/sbin/scw-builder-enter /usr/local/sbin/
RUN set -e; case "${ARCH}" in \
    armv7l|armhf|arm) \
        touch /tmp/lsb-release; \
	chmod +x /tmp/lsb-release; \
	PATH="$PATH:/tmp" /bin/sh -e /usr/local/sbin/scw-builder-enter; \
	rm -f /tmp/lsb-release; \
      ;; \
    x86_64|amd64) \
        yum install -y redhat-lsb-core; \
        /bin/sh -e /usr/local/sbin/scw-builder-enter; \
        yum clean all; \
      ;; \
    esac


RUN if [ "$ARCH" = "armv7l" ]; then YUM_OPTS=--nogpg; fi \
 && yum install ${YUM_OPTS} -y \
      bash \
      bash-completion \
      ca-certificates \
      cron \
      curl \
      ethstatus \
      haveged \
      htop \
      ioping \
      iotop \
      iperf \
      locate \
      make \
      mg \
      ntp \
      ntpdate \
      rsync \
      screen \
      socat \
      ssh \
      sudo \
      sysstat \
      tar \
      tcpdump \
      tmux \
      vim \
      wget \
 && yum clean all


# Patch rootfs
COPY ./overlay-image-tools ./overlay ./overlay-${ARCH} /


# Enable Scaleway services
RUN systemctl enable \
	scw-generate-ssh-keys \
	scw-fetch-ssh-keys \
	scw-gen-machine-id \
	scw-kernel-check \
	scw-sync-kernel-modules


# Hotfix reboot
RUN systemctl mask network

# Clean rootfs from image-builder
RUN /usr/local/sbin/scw-builder-leave
