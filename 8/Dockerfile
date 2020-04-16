## -*- docker-image-name: "scaleway/centos:7.4.1708" -*-
FROM centos:8.1.1911

# Environment
ENV SCW_BASE_IMAGE scaleway/centos:latest

# Adding and calling builder-enter
COPY ./overlay-base/usr/local/sbin/scw-signal-state /usr/local/sbin/
COPY ./overlay-base/etc/systemd/system/scw-signal-booted.service /etc/systemd/system/
COPY ./overlay-image-tools/usr/local/sbin/scw-builder-enter /usr/local/sbin/
COPY ./overlay/etc/dracut.conf /etc/
RUN dnf install -y epel-release
RUN dnf install -y dnf-plugin-ovl
RUN set -e; case "$(arch)" in \
	arm64v8|armhf|arm) \
	  touch /tmp/lsb-release; \
	chmod +x /tmp/lsb-release; \
	PATH="$PATH:/tmp" /bin/sh -e /usr/local/sbin/scw-builder-enter; \
	rm -f /tmp/lsb-release; \
	;; \
	x86_64|amd64|aarch64) \
	  dnf install -y redhat-lsb-core; \
	  /bin/sh -e /usr/local/sbin/scw-builder-enter; \
	  dnf clean all; \
	;; \
	esac

RUN dnf install -y cloud-init

RUN if [ "$(arch)" = "arm64v8" ]; then YUM_OPTS=--nogpg; fi \
 && dnf install ${YUM_OPTS} -y \
	curl \
	dhclient \
	dmidecode \
	kernel \
	initscripts \
	openssh-clients \
	openssh-server \
	passwd \
	selinux-policy \
	selinux-policy-targeted \
	sudo \
	&& case $(arch) in \
	x86_64) GRUB_ARCH="x64" ;;\
	i686) GRUB_ARCH="ia32" ;;\
	aarch64) GRUB_ARCH="aa64" ;;\
	esac \
	&& dnf install ${YUM_OPTS} -y grub2-efi-"$GRUB_ARCH" grub2-efi-modules grub2 grub2-pc \
	&& dnf clean all


# Patch rootfs
COPY ./overlay-image-tools ./overlay-base ./overlay /

# Enable Scaleway services
RUN systemctl enable \
	scw-generate-ssh-keys \
	scw-fetch-ssh-keys \
	scw-gen-machine-id \
	scw-kernel-check \
	scw-sync-kernel-modules \
	scw-signal-booted \
	scw-generate-net-config \
	scw-net-ipv6 \
	scw-generate-root-passwd \
	scw-set-hostname

# Configure Systemd
RUN systemctl set-default multi-user
RUN systemctl preset --preset-mode=full $(cat /etc/systemd/system-preset/*scw*.preset | cut -d' ' -f2 | tr '\n' ' ')

# Disable network zeroconf; breaks scw-signal-state
RUN if [ $(grep -c NOZEROCONF /etc/sysconfig/network) -eq 0 ]; then echo "NOZEROCONF=yes" >> /etc/sysconfig/network; fi

# Uncomment to disable SELinux on a local boot instance
#RUN sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

# This Centos service is not compatible with Scaleway kernel
# kdumpctl[1213]: Kdump is not supported on this kernel
RUN systemctl mask kdump.service

# Clean rootfs from image-builder
RUN /usr/local/sbin/scw-builder-leave
