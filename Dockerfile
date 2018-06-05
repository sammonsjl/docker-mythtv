FROM  ubuntu:bionic

ENV CONFIG_MODE=1 \
	DEBIAN_FRONTEND="noninteractive" \
	DISPLAY=:1 \
	HOME=/home/mythtv \
	GROUPID=121 \
	TERM="xterm" \
	TZ="America/Chicago" \
	USERID=120
	
ARG MARIADB_VERSION="10.2"
ARG MARIADB_URL="http://mirrors.coreix.net/mariadb/repo/$MARIADB_VERSION/ubuntu"
ARG MYTHTV_VERSION="0.29"
ARG MYTHTV_URL="http://ppa.launchpad.net/mythbuntu/$MYTHTV_VERSION/ubuntu/"
ARG S6_VERSION="v1.21.4.0"
ARG S6_URL="https://github.com/just-containers/s6-overlay/releases/download/$S6_VERSION/s6-overlay-amd64.tar.gz"

RUN apt-get update && apt-get install -y gnupg2

RUN apt-key adv --recv-keys --keyserver \
		hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8 \
	&& apt-key adv --recv-keys --keyserver \
		hkp://keyserver.ubuntu.com:80 1504888C \
	\
	&& echo "deb [arch=amd64,i386] $MARIADB_URL bionic main" \
		>> /etc/apt/sources.list.d/mariadb.list \
 	&& echo "deb $MYTHTV_URL bionic main" \
	 	>> /etc/apt/sources.list.d/mythbuntu.list \
	\
	&& apt-get update \
	&& apt-get dist-upgrade -y --no-install-recommends \
		-o Dpkg::Options::="--force-confold" \
	\
	&& apt-get install -y apt-utils locales curl tzdata \
		mariadb-server mythtv-backend-master mythweb \
		git x11vnc xvfb mate-desktop-environment-core net-tools \
	\
	&& cd /opt && git clone https://github.com/kanaka/noVNC.git \
	&& cd noVNC/utils && git clone \
		https://github.com/kanaka/websockify websockify \
	\
	&& locale-gen en_US.UTF-8 \
	\
	&& curl -o /tmp/s6-overlay.tar.gz -L ${S6_URL} \
	&& tar xfz /tmp/s6-overlay.tar.gz -C / \
	\
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY rootfs/ /

CMD ["/init"]

VOLUME ["/home/mythtv", "/var/lib/mysql", "/var/lib/mythtv"]