## -*- docker-image-name: "scaleway/centos:latest" -*-
ARG MULTIARCH_ARCH
FROM multiarch/centos:7.3.1611-${MULTIARCH_ARCH}-clean


# Environment
ENV SCW_BASE_IMAGE scaleway/centos:latest


# Adding and calling builder-enter
COPY ./overlay-${ARCH}/etc/yum.repos.d/ /etc/yum.repos.d/
COPY ./overlay-base/usr/local/sbin/scw-builder-enter /usr/local/sbin/
RUN yum install -y yum-plugin-ovl
RUN set -e; case "${ARCH}" in \
    armv7l|armhf|arm) \
        touch /tmp/lsb-release; \
	chmod +x /tmp/lsb-release; \
	PATH="$PATH:/tmp" /bin/sh -e /usr/local/sbin/scw-builder-enter; \
	rm -f /tmp/lsb-release; \
      ;; \
    x86_64|amd64|arm64) \
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
COPY ./overlay-base ./overlay ./overlay-${ARCH} /

# Remove root password
RUN passwd -d root

# Enable Scaleway services
RUN systemctl enable \
	scw-generate-ssh-keys \
	scw-fetch-ssh-keys \
	scw-gen-machine-id \
	scw-kernel-check \
	scw-sync-kernel-modules \
  scw-signal-booted

# Avoid duplicate the same action (with scw-generate-ssh-keys)
RUN systemctl mask sshd-keygen.service

# This Centos service is not compatible with Scaleway kernel
# kdumpctl[1213]: Kdump is not supported on this kernel
RUN systemctl mask kdump.service

# Hotfix reboot
RUN systemctl mask network

# Clean rootfs from image-builder
RUN /usr/local/sbin/scw-builder-leave
