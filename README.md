[![CircleCI](https://circleci.com/gh/emersonschulze/Wordpress-Docker/tree/master.svg?style=shield)](https://circleci.com/gh/emersonschulze/Wordpress-Docker/tree/master)
[![Docker Hub Automated Build](http://container.checkforupdates.com/badges/emersonschulze/emersondb)](https://hub.docker.com/r/emersonschulze/emersondb/)

# What is EmersonDB?

> EmersonDB is a fast, reliable, scalable, and easy to use open-source relational database system. EmersonDB Server is intended for mission-critical, heavy-load production systems as well as for embedding into mass-deployed software.

[https://emersondb.com/](https://emersondb.com/)

# TLDR

```bash
docker run --name emersondb emersonschulze/emersondb:latest
```

## Docker Compose

```yaml
version: '2'

services:
  emersondb:
    image: 'emersonschulze/emersondb:latest'
    ports:
      - '3306:3306'
```

# Get this image

The recommended way to get the Bitnami EmersonDB Docker Image is to pull the prebuilt image from the [Docker Hub Registry](https://hub.docker.com/r/emersonschulze/emersondb).

```bash
docker pull emersonschulze/emersondb:latest
```

To use a specific version, you can pull a versioned tag. You can view the
[list of available versions](https://hub.docker.com/r/emersonschulze/emersondb/tags/)
in the Docker Hub Registry.

```bash
docker pull emersonschulze/emersondb:[TAG]
```

If you wish, you can also build the image yourself.

```bash
docker build -t emersonschulze/emersondb:latest https://github.com/emersonschulze/Wordpress-Docker.git
```

# Persisting your database

If you remove the container all your data and configurations will be lost, and the next time you run the image the database will be reinitialized. To avoid this loss of data, you should mount a volume that will persist even after the container is removed.

**Note!**
If you have already started using your database, follow the steps on
[backing up](#backing-up-your-container) and [restoring](#restoring-a-backup) to pull the data from your running container down to your host.

The image exposes a volume at `/emersonschulze/emersondb` for the EmersonDB data and configurations. For persistence you can mount a directory at this location from your host. If the mounted directory is empty, it will be initialized on the first run.

```bash
docker run -v /path/to/emersondb-persistence:/emersonschulze/emersondb emersonschulze/emersondb:latest
```

or using Docker Compose:

```yaml
version: '2'

services:
  emersondb:
    image: 'emersonschulze/emersondb:latest'
    ports:
      - '3306:3306'
    volumes:
      - /path/to/emersondb-persistence:/emersonschulze/emersondb
```

# Connecting to other containers

Using [Docker container networking](https://docs.docker.com/engine/userguide/networking/), a EmersonDB server running inside a container can easily be accessed by your application containers.

Containers attached to the same network can communicate with each other using the container name as the hostname.

## Using the Command Line

In this example, we will create a EmersonDB client instance that will connect to the server instance that is running on the same docker network as the client.

### Step 1: Create a network

```bash
$ docker network create app-tier --driver bridge
```

### Step 2: Launch the EmersonDB server instance

Use the `--network app-tier` argument to the `docker run` command to attach the EmersonDB container to the `app-tier` network.

```bash
$ docker run -d --name emersondb-server \
    --network app-tier \
    emersonschulze/emersondb:latest
```

### Step 3: Launch your EmersonDB client instance

Finally we create a new container instance to launch the EmersonDB client and connect to the server created in the previous step:

```bash
$ docker run -it --rm \
    --network app-tier \
    emersonschulze/emersondb:latest mysql -h emersondb-server -u root
```

## Using Docker Compose

When not specified, Docker Compose automatically sets up a new network and attaches all deployed services to that network. However, we will explicitly define a new `bridge` network named `app-tier`. In this example we assume that you want to connect to the EmersonDB server from your own custom application image which is identified in the following snippet by the service name `myapp`.

```yaml
version: '2'

networks:
  app-tier:
    driver: bridge

services:
  emersondb:
    image: 'emersonschulze/emersondb:latest'
    networks:
      - app-tier
  myapp:
    image: 'YOUR_APPLICATION_IMAGE'
    networks:
      - app-tier
```

> **IMPORTANT**:
>
> 1. Please update the **YOUR_APPLICATION_IMAGE_** placeholder in the above snippet with your application image
> 2. In your application container, use the hostname `emersondb` to connect to the EmersonDB server

Launch the containers using:

```bash
$ docker-compose up -d
```

# Configuration

## Setting the root password on first run

Passing the `EMERSONDB_ROOT_PASSWORD` environment variable when running the image for the first time will set the password of the root user to the value of `EMERSONDB_ROOT_PASSWORD`.

```bash
docker run --name emersondb -e EMERSONDB_ROOT_PASSWORD=password123 emersonschulze/emersondb:latest
```

or using Docker Compose:

```yaml
version: '2'

services:
  emersondb:
    image: 'emersonschulze/emersondb:latest'
    ports:
      - '3306:3306'
    environment:
      - EMERSONDB_ROOT_PASSWORD=password123
```

**Warning** The `root` user is always created with remote access. It's suggested that the `EMERSONDB_ROOT_PASSWORD` env variable is always specified to set a password for the `root` user.

## Creating a database on first run

By passing the `EMERSONDB_DATABASE` environment variable when running the image for the first time, a database will be created. This is useful if your application requires that a database already exists, saving you from having to manually create the database using the MySQL client.

```bash
docker run --name emersondb -e EMERSONDB_DATABASE=my_database emersonschulze/emersondb:latest
```

or using Docker Compose:

```yaml
version: '2'

services:
  emersondb:
    image: 'emersonschulze/emersondb:latest'
    ports:
      - '3306:3306'
    environment:
      - EMERSONDB_DATABASE=my_database
```

## Creating a database user on first run

You can create a restricted database user that only has permissions for the database created with the [`EMERSONDB_DATABASE`](#creating-a-database-on-first-run) environment variable. To do this, provide the `EMERSONDB_USER` environment variable and to set a password for the database user provide the `EMERSONDB_PASSWORD` variable.

```bash
docker run --name emersondb \
  -e EMERSONDB_USER=my_user -e EMERSONDB_PASSWORD=my_password \
  -e EMERSONDB_DATABASE=my_database \
  emersonschulze/emersondb:latest
```

or using Docker Compose:

```yaml
version: '2'

services:
  emersondb:
    image: 'emersonschulze/emersondb:latest'
    ports:
      - '3306:3306'
    environment:
      - EMERSONDB_USER=my_user
      - EMERSONDB_PASSWORD=my_password
      - EMERSONDB_DATABASE=my_database
```

**Note!** The `root` user will still be created with remote access. Please ensure that you have specified a password for the `root` user using the `EMERSONDB_ROOT_PASSWORD` env variable.

## Setting up a replication cluster

A **zero downtime** EmersonDB master-slave [replication](https://dev.mysql.com/doc/refman/5.0/en/replication-howto.html) cluster can easily be setup with the Bitnami EmersonDB Docker image using the following environment variables:

 - `EMERSONDB_REPLICATION_MODE`: The replication mode. Possible values `master`/`slave`. No defaults.
 - `EMERSONDB_REPLICATION_USER`: The replication user created on the master on first run. No defaults.
 - `EMERSONDB_REPLICATION_PASSWORD`: The replication users password. No defaults.
 - `EMERSONDB_MASTER_HOST`: Hostname/IP of replication master (slave parameter). No defaults.
 - `EMERSONDB_MASTER_PORT`: Server port of the replication master (slave parameter). Defaults to `3306`.
 - `EMERSONDB_MASTER_USER`: User on replication master with access to `EMERSONDB_DATABASE` (slave parameter). Defaults to `root`
 - `EMERSONDB_MASTER_PASSWORD`: Password of user on replication master with access to `EMERSONDB_DATABASE` (slave parameter). No defaults.

In a replication cluster you can have one master and zero or more slaves. When replication is enabled the master node is in read-write mode, while the slaves are in read-only mode. For best performance its advisable to limit the reads to the slaves.

### Step 1: Create the replication master

The first step is to start the EmersonDB master.

```bash
docker run --name emersondb-master \
  -e EMERSONDB_ROOT_PASSWORD=root_password \
  -e EMERSONDB_REPLICATION_MODE=master \
  -e EMERSONDB_REPLICATION_USER=my_repl_user \
  -e EMERSONDB_REPLICATION_PASSWORD=my_repl_password \
  -e EMERSONDB_USER=my_user \
  -e EMERSONDB_PASSWORD=my_password \
  -e EMERSONDB_DATABASE=my_database \
  emersonschulze/emersondb:latest
```

In the above command the container is configured as the `master` using the `EMERSONDB_REPLICATION_MODE` parameter. A replication user is specified using the `EMERSONDB_REPLICATION_USER` and `EMERSONDB_REPLICATION_PASSWORD` parameters.

### Step 2: Create the replication slave

Next we start a EmersonDB slave container.

```bash
docker run --name emersondb-slave --link emersondb-master:master \
  -e EMERSONDB_ROOT_PASSWORD=root_password \
  -e EMERSONDB_REPLICATION_MODE=slave \
  -e EMERSONDB_REPLICATION_USER=my_repl_user \
  -e EMERSONDB_REPLICATION_PASSWORD=my_repl_password \
  -e EMERSONDB_MASTER_HOST=master \
  -e EMERSONDB_MASTER_USER=my_user \
  -e EMERSONDB_MASTER_PASSWORD=my_password \
  -e EMERSONDB_USER=my_user \
  -e EMERSONDB_PASSWORD=my_password \
  -e EMERSONDB_DATABASE=my_database \
  emersonschulze/emersondb:latest
```

In the above command the container is configured as a `slave` using the `EMERSONDB_REPLICATION_MODE` parameter. The `EMERSONDB_MASTER_HOST`, `EMERSONDB_MASTER_USER` and `EMERSONDB_MASTER_PASSWORD` parameters are used by the slave to connect to the master and take a dump of the existing data in the database identified by `EMERSONDB_DATABASE`. The replication user credentials are specified using the `EMERSONDB_REPLICATION_USER` and `EMERSONDB_REPLICATION_PASSWORD` parameters and should be the same as the one specified on the master.

> **Note**! The cluster only replicates the database specified in the `EMERSONDB_DATABASE` parameter.

You now have a two node EmersonDB master/slave replication cluster up and running. You can scale the cluster by adding/removing slaves without incurring any downtime.

With Docker Compose the master/slave replication can be setup using:

```yaml
version: '2'

services:
  emersondb-master:
    image: 'emersonschulze/emersondb:latest'
    ports:
      - '3306'
    volumes:
      - /path/to/emersondb-persistence:/emersonschulze/emersondb
    environment:
      - EMERSONDB_REPLICATION_MODE=master
      - EMERSONDB_REPLICATION_USER=repl_user
      - EMERSONDB_REPLICATION_PASSWORD=repl_password
      - EMERSONDB_ROOT_PASSWORD=root_password
      - EMERSONDB_USER=my_user
      - EMERSONDB_PASSWORD=my_password
      - EMERSONDB_DATABASE=my_database
  emersondb-slave:
    image: 'emersonschulze/emersondb:latest'
    ports:
      - '3306'
    depends_on:
      - emersondb-master
    environment:
      - EMERSONDB_REPLICATION_MODE=slave
      - EMERSONDB_REPLICATION_USER=repl_user
      - EMERSONDB_REPLICATION_PASSWORD=repl_password
      - EMERSONDB_MASTER_HOST=emersondb-master
      - EMERSONDB_MASTER_PORT=3306
      - EMERSONDB_MASTER_USER=my_user
      - EMERSONDB_MASTER_PASSWORD=my_password
      - EMERSONDB_ROOT_PASSWORD=root_password
      - EMERSONDB_USER=my_user
      - EMERSONDB_PASSWORD=my_password
      - EMERSONDB_DATABASE=my_database
```

Scale the number of slaves using:

```bash
docker-compose scale emersondb-master=1 emersondb-slave=3
```

The above command scales up the number of slaves to `3`. You can scale down in the same manner.

> **Note**: You should not scale up/down the number of master nodes. Always have only one master node running.

## Configuration file

The image looks for configuration in the `conf/` directory of `/emersonschulze/emersondb`. As mentioned in [Persisting your database](#persisting-your-data) you can mount a volume at this location and copy your own custom `my_custom.cnf` file in the `conf/` directory. That file will be included in the main configuration file and will overwrite any configuration you want to modify.

For example, in order to override the max_allowed_packet directive:

# Step 1: Write your my_custom.cnf file with the following content.
```
[mysqld]
max_allowed_packet=32M
```

# Step 2: Run the emersonDB image with the designed volume attached.
```
docker run --name emersondb -v /path/to/my_custom_cnf_directory:/emersonschulze/emersondb emersonschulze/emersondb:latest
```
After that, your changes will be taken into account in the server's behaviour.

### Step 1: Run the EmersonDB image

Run the EmersonDB image, mounting a directory from your host.

```bash
docker run --name emersondb -v /path/to/emersondb-persistence:/emersonschulze/emersondb emersonschulze/emersondb:latest
```

or using Docker Compose:

```yaml
version: '2'

services:
  emersondb:
    image: 'emersonschulze/emersondb:latest'
    ports:
      - '3306:3306'
    volumes:
      - /path/to/emersondb-persistence:/emersonschulze/emersondb
```

### Step 2: Edit the configuration

Edit the configuration on your host using your favorite editor.

```bash
vi /path/to/emersondb-persistence/conf/my.cnf
```

### Step 3: Restart EmersonDB

After changing the configuration, restart your EmersonDB container for changes to take effect.

```bash
docker restart emersondb
```

or using Docker Compose:

```bash
docker-compose restart emersondb
```

**Further Reading:**

  - [Server Option and Variable Reference](https://dev.mysql.com/doc/refman/5.1/en/mysqld-option-tables.html)

# Logging

The Bitnami EmersonDB Docker image sends the container logs to the `stdout`. To view the logs:

```bash
docker logs emersondb
```

or using Docker Compose:

```bash
docker-compose logs emersondb
```

You can configure the containers [logging driver](https://docs.docker.com/engine/admin/logging/overview/) using the `--log-driver` option if you wish to consume the container logs differently. In the default configuration docker uses the `json-file` driver.

# Maintenance

## Backing up your container

To backup your data, configuration and logs, follow these simple steps:

### Step 1: Stop the currently running container

```bash
docker stop emersondb
```

or using Docker Compose:

```bash
docker-compose stop emersondb
```

### Step 2: Run the backup command

We need to mount two volumes in a container we will use to create the backup: a directory on your host to store the backup in, and the volumes from the container we just stopped so we can access the data.

```bash
docker run --rm -v /path/to/emersondb-backups:/backups --volumes-from emersondb busybox \
  cp -a /emersonschulze/emersondb:latest /backups/latest
```

or using Docker Compose:

```bash
docker run --rm -v /path/to/emersondb-backups:/backups --volumes-from `docker-compose ps -q emersondb` busybox \
  cp -a /emersonschulze/emersondb:latest /backups/latest
```

## Restoring a backup

Restoring a backup is as simple as mounting the backup as volumes in the container.

```bash
docker run -v /path/to/emersondb-backups/latest:/emersonschulze/emersondb emersonschulze/emersondb:latest
```

or using Docker Compose:

```yaml
version: '2'

services:
  emersondb:
    image: 'emersonschulze/emersondb:latest'
    ports:
      - '3306:3306'
    volumes:
      - /path/to/emersondb-backups/latest:/emersonschulze/emersondb
```

## Upgrade this image

Bitnami provides up-to-date versions of EmersonDB, including security patches, soon after they are made upstream. We recommend that you follow these steps to upgrade your container.

### Step 1: Get the updated image

```bash
docker pull emersonschulze/emersondb:latest
```

or if you're using Docker Compose, update the value of the image property to
`emersonschulze/emersondb:latest`.

### Step 2: Stop and backup the currently running container

Before continuing, you should backup your container's data, configuration and logs.

Follow the steps on [creating a backup](#backing-up-your-container).

### Step 3: Remove the currently running container

```bash
docker rm -v emersondb
```

or using Docker Compose:

```bash
docker-compose rm -v emersondb
```

### Step 4: Run the new image

Re-create your container from the new image, [restoring your backup](#restoring-a-backup) if necessary.

```bash
docker run --name emersondb emersonschulze/emersondb:latest
```

or using Docker Compose:

```bash
docker-compose start emersondb
```

# Testing

This image is tested for expected runtime behavior, using the [Bats](https://github.com/sstephenson/bats) testing framework. You can run the tests on your machine using the `bats` command.

```
bats test.sh
```

# Notable Changes

## 10.1.13-r0

- All volumes have been merged at `/emersonschulze/emersondb`. Now you only need to mount a single volume at `/emersonschulze/emersondb` for persistence.
- The logs are always sent to the `stdout` and are no longer collected in the volume.

# Contributing

We'd love for you to contribute to this container. You can request new features by creating an [issue](https://github.com/emersonschulze/Wordpress-Docker/issues), or submit a [pull request](https://github.com/emersonschulze/Wordpress-Docker/pulls) with your contribution.

# Issues

If you encountered a problem running this container, you can file an [issue](https://github.com/emersonschulze/Wordpress-Docker/issues). For us to provide better support, be sure to include the following information in your issue:

- Host OS and version
- Docker version (`docker version`)
- Output of `docker info`
- Version of this container (`echo $BITNAMI_IMAGE_VERSION` inside the container)
- The command you used to run the container, and any relevant output you saw (masking any sensitive information)

# License

Copyright (c) 2015-2016 Bitnami

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
