NAME =			centos
VERSION =		7
VERSION_ALIASES =	merlinthp-2015-03-16 latest
TITLE =			CentOS 7
DESCRIPTION =		CentOS 7
SOURCE_URL =		https://github.com/scaleway/image-centos
VENDOR_URL =		https://www.centos.org/

IMAGE_VOLUME_SIZE =	50G
IMAGE_BOOTSCRIPT =	latest
IMAGE_NAME =		CentOS 7 (beta)


## Image tools  (https://github.com/scaleway/image-tools)
all:    docker-rules.mk
docker-rules.mk:
	wget -qO - http://j.mp/scw-builder | bash
-include docker-rules.mk
