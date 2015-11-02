FROM debian:jessie
MAINTAINER Samuel <sam@infinitely.io>

RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf

RUN apt-get update
RUN apt-get upgrade -y

# Install system packages

RUN apt-get install -y apt-transport-https wget

# Add Mariadb repo

ADD MariaDB.list /etc/apt/sources.list.d/MariaDB.list
RUN wget --no-check-certificate -O /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.10.0/confd-0.10.0-linux-amd64
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db

# Add gluster repo

RUN wget -O - http://download.gluster.org/pub/gluster/glusterfs/3.6/3.6.4/Debian/jessie/pub.key | apt-key add -
RUN echo deb http://download.gluster.org/pub/gluster/glusterfs/3.6/3.6.4/Debian/jessie/apt jessie main > /etc/apt/sources.list.d/gluster.list

# Update repo

RUN apt-get update

# Install Supervisord

RUN apt-get install -y supervisor

# Install Glusterfs

RUN apt-get install -y glusterfs-client

# Install Password generator

RUN apt-get install -y pwgen

# Install Mariadb 10.0

RUN pwgen -1 -s > /opt/mariadb_password
RUN echo mariadb-galera-server-10.0 mysql-server/root_password password $(cat /opt/mariadb_password) | debconf-set-selections
RUN echo mariadb-galera-server-10.0 mysql-server/root_password_again password $(cat /opt/mariadb_password) | debconf-set-selections
RUN LC_ALL=en_US.utf8 DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::='--force-confnew' -y install mariadb-galera-server mariadb-client

# RUN service mysql restart

ADD bin/execute.bash /usr/local/bin/execute
ADD bin/mariadb.bash /usr/local/bin/mariadb
ADD bin/gluster.bash /usr/local/bin/gluster

# Modify the programs files permissions

RUN chmod 755 /usr/local/bin/execute
RUN chmod 755 /usr/local/bin/mariadb
RUN chmod 755 /usr/local/bin/gluster

ENV TERM dumb

EXPOSE 3306 4444 4567 4568

ENTRYPOINT ["execute"]
