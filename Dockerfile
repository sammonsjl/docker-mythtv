FROM  ubuntu:bionic

ENV CONFIG_MODE=1 \
	DEBIAN_FRONTEND="noninteractive" \
	DISPLAY=:1 \
	HOME=/home/mythtv \
	GROUPID=121 \
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US:en \
	LC_ALL=en_US.UTF-8 \
	TERM="xterm" \
	TZ="America/Chicago" \
	USERID=120
	
ARG MYTHTV_VERSION="30"
ARG MYTHTV_URL="http://ppa.launchpad.net/mythbuntu/$MYTHTV_VERSION/ubuntu/"
ARG S6_VERSION="v1.21.4.0"
ARG S6_URL="https://github.com/just-containers/s6-overlay/releases/download/$S6_VERSION/s6-overlay-amd64.tar.gz"

RUN apt-get update && apt-get install -y gnupg2

RUN apt-key adv --recv-keys --keyserver \
		hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8 \
	&& apt-key adv --recv-keys --keyserver \
		hkp://keyserver.ubuntu.com:80 1504888C \
	\
 	&& echo "deb $MYTHTV_URL bionic main" \
	 	>> /etc/apt/sources.list.d/mythbuntu.list \
	\
	&& apt-get update \
	&& apt-get dist-upgrade -y --no-install-recommends \
		-o Dpkg::Options::="--force-confold" \
	\
	&& apt-get install -y mariadb-server apt-utils locales curl tzdata  \
		git x11vnc xvfb mate-desktop-environment-core net-tools \
	\
	&& apt-get install -y  \
		mythtv-backend-master mythweb xmltv xmltv-util \
	\
	&& wget https://nice.net.nz/scripts/tv_grab_nz-py -O /usr/bin/tv_grab_nz-py \
	&& chmod a+x /usr/bin/tv_grab_nz-py \
	\
	&& sed -i 's/3306/6506/g' /etc/mysql/mariadb.conf.d/50-server.cnf \
	&& sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf \
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
