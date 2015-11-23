# A docker image to deploy mysql as container

This docker image is a based image to run a mysql instance inside a container

## Install

```
$ git clone https://github.com/Soletic/hosting-docker-ubuntu.git ./ubuntu
$ git clone https://github.com/Soletic/hosting-docker-mysql.git ./mysql
$ docker build --pull -t soletic/ubuntu ./ubuntu
$ docker build -t soletic/mysql ./mysql
```

## Run a container

### Basic example

```
$ docker run -d --name=example.mysql -e WORKER_NAME=example -p 20136:3306 soletic/mysql
```

### Share host directory to store backups

```
$ docker run -d --name=example.mysql -e WORKER_NAME=example -v /path/host/backup:/home/backup -p 20136:3306 soletic/mysql
```

* WORKER_NAME : a user name without spaces and used to setup account for mysql

## Running options

The image define many environment variables to configure the image running :

* MYSQL_MAX_QUERIES_PER_HOUR (default 10000000)
* MYSQL_MAX_UPDATES_PER_HOUR (default 1000000)
* MYSQL_MAX_CONNECTIONS_PER_HOUR (default 5000)
* MYSQL_MAX_USER_CONNECTIONS (default 50)
* WORKER_NAME : user id used for the worker