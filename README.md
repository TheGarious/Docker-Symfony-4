docker-symfony-4
==============

[![Build Status](https://secure.travis-ci.org/eko/docker-symfony.png?branch=master)](http://travis-ci.org/eko/docker-symfony)


# Installation

First, clone this repository:

```bash
git clone yourgit.git into project/local.project.com

For stop the docker services:

```bash
./docker.sh start
```

For stop the docker services:

```bash
./docker.sh build
```

Rebuild all container:

```bash
./docker.sh stop
```

List container started:

```bash
./docker.sh stop
```

For more information:
```bash
./docker.sh build -h
./docker.sh start -h
./docker.sh stop -h
```

You can access Nginx and Symfony application logs in the following directories on your host machine:

* `logs/nginx`
* `logs/symfony`

# Use Kibana!

You can also use Kibana to visualize Nginx & Symfony logs by visiting `http://symfony.dev:81`.
