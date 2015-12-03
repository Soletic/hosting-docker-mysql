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

exec mysqld_safe