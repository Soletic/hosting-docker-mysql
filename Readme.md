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

Environment variables you have to provide :

* WORKER_NAME : user name used to run the server and create an account for mysql connection

### Basic example

```
$ docker run -d --name=example.mysql -e WORKER_NAME=example -p 20136:3306 soletic/mysql
```

### Share host directory to store backups

```
$ docker run -d --name=example.mysql -e WORKER_NAME=example -v /path/host/backup:/home/backup -p 20136:3306 soletic/mysql
```

### Share host directory to store mysql data

```
$ docker run -d --name=example.mysql -e WORKER_NAME=example -v /path/host/backup:/home/backup -v /path/host/mysql:/var/lib/mysql -p 20136:3306 soletic/mysql
```

## Running options

The image define many environment variables to configure the image running :

* MYSQL_MAX_QUERIES_PER_HOUR (default 10000000)
* MYSQL_MAX_UPDATES_PER_HOUR (default 1000000)
* MYSQL_MAX_CONNECTIONS_PER_HOUR (default 5000)
* MYSQL_MAX_USER_CONNECTIONS (default 50)
* WORKER_NAME : user name used for the worker
* WORKER_UID : user id used for the worker name