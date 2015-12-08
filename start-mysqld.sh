#!/bin/bash

# mysql conf
sed -ri -e "s/^key_buffer.*/key_buffer_size = 10M/" \
    -e "s/^myisam\-recover.*/myisam\-recover\-options = BACKUP/" \
    -e "s/^bind-address/#bind-address/" /etc/mysql/my.cnf

# Change user id of user mysql with worker uid
mysql_user_id=$(id -u mysql)
if [ $mysql_user_id != ${WORKER_UID} ]; then
	mysql_group_id=$(id -g mysql)
	usermod -u ${WORKER_UID} mysql
	groupmod -g ${WORKER_UID} mysql
	find / -uid $mysql_user_id ! -wholename "/proc*" -exec chown mysql {} \;
	find / -gid $mysql_group_id ! -wholename "/proc*" -exec chgrp mysql {} \;
fi

# Mysql Init
if [[ ! -d ${DATA_VOLUME_MYSQL_DB}/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in ${DATA_VOLUME_MYSQL_DB}"
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"  
    /root/scripts/init_mysql.sh
else
    echo "=> Using an existing volume of MySQL"
fi

ROOT_CREDENTIALS=$(head -n 1 ${DATA_VOLUME_MYSQL_BACKUP}/credentials)
IFS=':' read -r -a ROOT_CREDENTIALS <<< "$ROOT_CREDENTIALS"
ROOT_PASSWORD="${ROOT_CREDENTIALS[1]}"
sed -ri -e "s/MYADMIN=.+/MYADMIN=\"mysqladmin -uroot -p$ROOT_PASSWORD\"/" /etc/logrotate.d/mysql-server

exec mysqld_safe