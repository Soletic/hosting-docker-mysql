FROM soletic/ubuntu
MAINTAINER Sol&TIC <serveur@soletic.org>

ENV WORKER_NAME soletic

# MYSQL
RUN apt-get -y update && \
  apt-get -y install supervisor mysql-server pwgen

# Environment variables of mysql
ENV MYSQL_MAX_QUERIES_PER_HOUR 10000000
ENV MYSQL_MAX_UPDATES_PER_HOUR 1000000
ENV MYSQL_MAX_CONNECTIONS_PER_HOUR 5000
ENV MYSQL_MAX_USER_CONNECTIONS 50
ENV MYSQL_USERNAME ${HOST_NAME}
ENV MYSQL_PASSWORD p@ssword

# Environment variables of data
ENV DATA_VOLUME_MYSQL_DB /var/lib/mysql
ENV DATA_VOLUME_MYSQL_BACKUP /home/backup
ENV DATA_VOLUME_LOGS /var/log

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# VOLUMES
VOLUME [ "${DATA_VOLUME_LOGS}", "${DATA_VOLUME_MYSQL_BACKUP}" ]

# ADD FILES TO FILE SYSTEM
ADD init_mysql.sh /root/scripts/init_mysql.sh
ADD start-mysqld.sh /root/scripts/start-mysqld.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# BACKUP MYSQL
ADD automysqlbackup.sh /etc/cron.daily/automysqlbackup
RUN chmod 755 /etc/cron.daily/automysqlbackup

# MAKE SCRIPT EXCUTABLE
RUN chmod 755 /root/scripts/*.sh

EXPOSE 3306