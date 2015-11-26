#!/bin/bash

/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 1
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

# SET A RANDOM ROOT PASSWORD

PASS=${MYSQL_PASS:-$(pwgen -s 12 1)}
_word=$( [ ${MYSQL_PASS} ] && echo "preset" || echo "random" )
echo "=> Creating MySQL root user with ${_word} password"

mysql -uroot <<-EOSQL
			-- What's done in this file shouldn't be replicated
			--  or products like mysql-fabric won't work
			SET @@SESSION.SQL_LOG_BIN=0;
			DELETE FROM mysql.user ;
			FLUSH PRIVILEGES;
			CREATE USER 'root'@'%' IDENTIFIED BY '$PASS' ;
			GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
			DROP DATABASE IF EXISTS test ;
			FLUSH PRIVILEGES ;
		EOSQL

# SET A DEFAULT USER FOR DATABASES
USERPASS=${MYSQL_PASS:-$(pwgen -s 12 1)}
_userword=$( [ ${MYSQL_PASS} ] && echo "preset" || echo "random" )
echo "=> Creating MySQL user for database connections with ${_userword} password"

mysql -uroot -p$PASS <<-EOSQL
			SET @@SESSION.SQL_LOG_BIN=0;
			CREATE USER '${WORKER_NAME}'@'%' IDENTIFIED BY '$USERPASS';
			GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, FILE, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, CREATE VIEW, EVENT, TRIGGER, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, CREATE USER, EXECUTE
				ON *.* TO '${WORKER_NAME}'@'%'
				WITH 
					MAX_QUERIES_PER_HOUR ${MYSQL_MAX_QUERIES_PER_HOUR} 
					MAX_CONNECTIONS_PER_HOUR ${MYSQL_MAX_CONNECTIONS_PER_HOUR} 
					MAX_UPDATES_PER_HOUR ${MYSQL_MAX_UPDATES_PER_HOUR} 
					MAX_USER_CONNECTIONS ${MYSQL_MAX_USER_CONNECTIONS};
			FLUSH PRIVILEGES;
		EOSQL

echo "=> Done!"

# CREATE DEFAULT DATABASE
echo "=> Creating default database with name db"
mysql -uroot -p$PASS <<-EOSQL
			SET @@SESSION.SQL_LOG_BIN=0;
			CREATE DATABASE `${WORKER_NAME}`;
		EOSQL
echo "=> Done!"

echo "========================================================================"
echo "You can now connect to this MySQL Server using:"
echo ""
echo "    mysql -uroot -p$PASS -h<host> -P<port>"
echo "    mysql -u${WORKER_NAME} -p$USERPASS -h<host> -P<port>"
echo ""
echo "========================================================================"

echo "root:$PASS" > ${DATA_VOLUME_MYSQL_BACKUP}/credentials
echo "${WORKER_NAME}:$USERPASS" >> ${DATA_VOLUME_MYSQL_BACKUP}/credentials
export MYSQL_PASSWORD=$USERPASS

mysqladmin -uroot -p$PASS shutdown
