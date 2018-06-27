## -*- docker-image-name: "scaleway/centos:7.4.1708" -*-
FROM library/centos:centos7

# Environment
ENV SCW_BASE_IMAGE scaleway/centos:latest

# Adding and calling builder-enter
COPY ./overlay-base/usr/local/sbin/scw-signal-state /usr/local/sbin/
COPY ./overlay-base/etc/systemd/system/scw-signal-booted.service /etc/systemd/system/
COPY ./overlay-image-tools/usr/local/sbin/scw-builder-enter /usr/local/sbin/
COPY ./overlay/etc/dracut.conf /etc/
RUN yum install -y yum-plugin-ovl
RUN set -e; case "$(arch)" in \
	armv7l|armhf|arm) \
	  touch /tmp/lsb-release; \
	chmod +x /tmp/lsb-release; \
	PATH="$PATH:/tmp" /bin/sh -e /usr/local/sbin/scw-builder-enter; \
	rm -f /tmp/lsb-release; \
	;; \
	x86_64|amd64|aarch64) \
	  yum install -y redhat-lsb-core; \
	  /bin/sh -e /usr/local/sbin/scw-builder-enter; \
	  yum clean all; \
	;; \
	esac

RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm; \
    yum install -y https://github.com/scaleway/image-tools/releases/download/cloud-init/cloud-init-18.2.5.g01ff5c2e.scaleway-1.fc28.noarch.rpm

RUN if [ "$(arch)" = "armv7l" ]; then YUM_OPTS=--nogpg; fi \
 && yum install ${YUM_OPTS} -y \
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
	&& yum install ${YUM_OPTS} -y grub2-efi-"$GRUB_ARCH" grub2-efi-modules grub2 grub2-pc \
	&& yum clean all


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

# Disable systemd units that are handled by cloud-init
RUN cd /etc/systemd/system && for I in $(ls scw* | egrep -v 'gen-machine-id|generate-root-passwd');do systemctl disable $I;done

# Enable root login to stay backward-compatible
# Otherwise cloud-init disables it
RUN sed -i 's/disable_root: true/disable_root: false/' /etc/cloud/cloud.cfg

# Disable network zeroconf; breaks scw-signal-state
RUN if [ $(grep -c NOZEROCONF /etc/sysconfig/network) -eq 0 ]; then echo "NOZEROCONF=yes" >> /etc/sysconfig/network; fi

# Uncomment to disable SELinux on a local boot instance
#RUN sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

# This Centos service is not compatible with Scaleway kernel
# kdumpctl[1213]: Kdump is not supported on this kernel
RUN systemctl mask kdump.service

# Clean rootfs from image-builder
RUN /usr/local/sbin/scw-builder-leave
